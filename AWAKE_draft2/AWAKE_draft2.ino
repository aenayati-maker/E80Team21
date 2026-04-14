/********
E80 Lab 7 Dive Activity Code
********/

#include <Arduino.h>
#include <Wire.h>
#include <avr/io.h>
#include <avr/interrupt.h>

#include <Pinouts.h>
#include <TimingOffsets.h>
#include <SensorGPS.h>
#include <SensorIMU.h>
#include <XYStateEstimator.h>
#include <ZStateEstimator.h>
#include <ADCSampler.h>
#include <ErrorFlagSampler.h>
#include <ButtonSampler.h>
#include <MotorDriver.h>
#include <Logger.h>
#include <Printer.h>
#include <DepthControl.h>
#define UartSerial Serial1
#include <GPSLockLED.h>
#include "Adafruit_LTR329_LTR303.h"

/////////////////////////* GLOBAL VARIABLES *////////////////////////

MotorDriver motor_driver;
XYStateEstimator xy_state_estimator;
ZStateEstimator z_state_estimator;
DepthControl depth_control;
SensorGPS gps;
Adafruit_GPS GPS(&UartSerial);
ADCSampler adc;
ErrorFlagSampler ef;
ButtonSampler button_sampler;
SensorIMU imu;
Logger logger;
Printer printer;
GPSLockLED led;

// ---------------- LIGHT SENSOR ----------------
Adafruit_LTR329 ltr;
bool ltr_enabled = false;
uint16_t visible_plus_ir = 0;
uint16_t infrared = 0;
bool lightValid = false;

// loop timing
int loopStartTime;
int currentTime;
volatile bool EF_States[NUM_FLAGS] = {1,1,1};

////////////////////////* SETUP *////////////////////////////////

void setup() {

  logger.include(&imu);
  logger.include(&gps);
  logger.include(&xy_state_estimator);
  logger.include(&z_state_estimator);
  logger.include(&depth_control);
  logger.include(&motor_driver);
  logger.include(&adc);
  logger.include(&ef);
  logger.include(&button_sampler);
  logger.init();

  printer.init();
  ef.init();
  button_sampler.init();
  imu.init();

  // ---------------- LIGHT SENSOR INIT ----------------
  printer.printMessage("Searching for LTR-329", 10);

  if (ltr.begin()) {

    ltr_enabled = true;

    printer.printMessage("Found LTR sensor!", 10);

    ltr.setGain(LTR3XX_GAIN_2);
    ltr.setIntegrationTime(LTR3XX_INTEGTIME_100);
    ltr.setMeasurementRate(LTR3XX_MEASRATE_200);

  } else {

    ltr_enabled = false;

    printer.printMessage("LTR not found (disabled)", 10);
  }

  // ---------------- OTHER SYSTEMS ----------------
  UartSerial.begin(9600);
  gps.init(&GPS);
  motor_driver.init();
  led.init();

  int diveDelay = 10000;

  const int num_depth_waypoints = 2;
  double depth_waypoints[] = {0.5, 1};
  depth_control.init(num_depth_waypoints, depth_waypoints, diveDelay);

  xy_state_estimator.init();
  z_state_estimator.init();

  printer.printMessage("Starting main loop", 10);

  loopStartTime = millis();
  printer.lastExecutionTime            = loopStartTime - LOOP_PERIOD + PRINTER_LOOP_OFFSET;
  imu.lastExecutionTime                = loopStartTime - LOOP_PERIOD + IMU_LOOP_OFFSET;
  adc.lastExecutionTime                = loopStartTime - LOOP_PERIOD + ADC_LOOP_OFFSET;
  ef.lastExecutionTime                = loopStartTime - LOOP_PERIOD + ERROR_FLAG_LOOP_OFFSET;
  button_sampler.lastExecutionTime     = loopStartTime - LOOP_PERIOD + BUTTON_LOOP_OFFSET;
  xy_state_estimator.lastExecutionTime = loopStartTime - LOOP_PERIOD + XY_STATE_ESTIMATOR_LOOP_OFFSET;
  z_state_estimator.lastExecutionTime  = loopStartTime - LOOP_PERIOD + Z_STATE_ESTIMATOR_LOOP_OFFSET;
  depth_control.lastExecutionTime      = loopStartTime - LOOP_PERIOD + DEPTH_CONTROL_LOOP_OFFSET;
  logger.lastExecutionTime             = loopStartTime - LOOP_PERIOD + LOGGER_LOOP_OFFSET;
}

//////////////////////////////* LOOP */////////////////////////

void loop() {

  currentTime = millis();

  ////////////////////// PRINTER //////////////////////
  if (currentTime - printer.lastExecutionTime > LOOP_PERIOD) {

    printer.lastExecutionTime = currentTime;

    printer.printValue(0, adc.printSample());
    printer.printValue(1, button_sampler.printState());
    printer.printValue(2, logger.printState());
    printer.printValue(3, gps.printState());
    printer.printValue(4, xy_state_estimator.printState());
    printer.printValue(5, z_state_estimator.printState());
    printer.printValue(6, depth_control.printWaypointUpdate());
    printer.printValue(7, depth_control.printString());
    printer.printValue(8, motor_driver.printState());
    printer.printValue(9, imu.printRollPitchHeading());
    printer.printValue(10, imu.printAccels());

    // LIGHT SENSOR OUTPUT (SAFE)
    if (lightValid) {
      printer.printValue(11, String(visible_plus_ir) + "," + String(infrared));
    } else {
      printer.printValue(11, "NO LIGHT DATA");
    }

    printer.printToSerial();
  }

  ////////////////////// CONTROL //////////////////////
  if (currentTime - depth_control.lastExecutionTime > LOOP_PERIOD) {
    depth_control.lastExecutionTime = currentTime;

    if (depth_control.diveState) {
      depth_control.complete = false;

      if (!depth_control.atDepth) {
        depth_control.dive(&z_state_estimator.state, currentTime);
      } else {
        depth_control.diveState = false;
        depth_control.surfaceState = false; //changed to false
      }

      motor_driver.drive(depth_control.uV, depth_control.uV, depth_control.uV);
    }

    if (depth_control.surfaceState) {

      if (!depth_control.atSurface) {
        depth_control.surface(&z_state_estimator.state);
      } else if (depth_control.complete) {
        delete[] depth_control.wayPoints;
      }

      motor_driver.drive(depth_control.uV, depth_control.uV, depth_control.uV);
    }
  }

  ////////////////////// ADC //////////////////////
  if (currentTime - adc.lastExecutionTime > LOOP_PERIOD) {
    adc.lastExecutionTime = currentTime;
    adc.updateSample();
  }

  ////////////////////// ERROR FLAGS //////////////////////
  if (currentTime - ef.lastExecutionTime > LOOP_PERIOD) {
    ef.lastExecutionTime = currentTime;

    attachInterrupt(digitalPinToInterrupt(ERROR_FLAG_A), EFA_Detected, LOW);
    attachInterrupt(digitalPinToInterrupt(ERROR_FLAG_B), EFB_Detected, LOW);
    attachInterrupt(digitalPinToInterrupt(ERROR_FLAG_C), EFC_Detected, LOW);

    delay(5);

    detachInterrupt(digitalPinToInterrupt(ERROR_FLAG_A));
    detachInterrupt(digitalPinToInterrupt(ERROR_FLAG_B));
    detachInterrupt(digitalPinToInterrupt(ERROR_FLAG_C));

    ef.updateStates(EF_States[0], EF_States[1], EF_States[2]);

    EF_States[0] = 1;
    EF_States[1] = 1;
    EF_States[2] = 1;
  }

  ////////////////////// BUTTON //////////////////////
  if (currentTime - button_sampler.lastExecutionTime > LOOP_PERIOD) {
    button_sampler.lastExecutionTime = currentTime;
    button_sampler.updateState();
  }

  ////////////////////// IMU //////////////////////
  if (currentTime - imu.lastExecutionTime > LOOP_PERIOD) {
    imu.lastExecutionTime = currentTime;
    imu.read();
  }

  ////////////////////// LIGHT SENSOR (SAFE) //////////////////////
  if (ltr_enabled && ltr.newDataAvailable()) {
    lightValid = ltr.readBothChannels(visible_plus_ir, infrared);
  } else {
    lightValid = false;
  }

  ////////////////////// GPS //////////////////////
  gps.read(&GPS);

  ////////////////////// XY ESTIMATOR //////////////////////
  if (currentTime - xy_state_estimator.lastExecutionTime > LOOP_PERIOD) {
    xy_state_estimator.lastExecutionTime = currentTime;
    xy_state_estimator.updateState(&imu.state, &gps.state);
  }

  ////////////////////// Z ESTIMATOR //////////////////////
  if (currentTime - z_state_estimator.lastExecutionTime > LOOP_PERIOD) {
    z_state_estimator.lastExecutionTime = currentTime;
    z_state_estimator.updateState(analogRead(PRESSURE_PIN));
  }

  ////////////////////// LED //////////////////////
  if (currentTime - led.lastExecutionTime > LOOP_PERIOD) {
    led.lastExecutionTime = currentTime;
    led.flashLED(&gps.state);
  }

  ////////////////////// LOGGER //////////////////////
  if (currentTime - logger.lastExecutionTime > LOOP_PERIOD && logger.keepLogging) {
    logger.lastExecutionTime = currentTime;
    logger.log();
  }
}

//////////////////////// INTERRUPTS ////////////////////////

void EFA_Detected(void){ EF_States[0] = 0; }
void EFB_Detected(void){ EF_States[1] = 0; }
void EFC_Detected(void){ EF_States[2] = 0; }