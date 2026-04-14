#include <Arduino.h>
#include <Wire.h>
#include "Adafruit_LTR329_LTR303.h"
#include <ADCSampler.h>
#include <Pinouts.h>
#include <ZStateEstimator.h>


Adafruit_LTR329 ltr;
ADCSampler adc;

String latestADC = "";
unsigned long lastTime = 0;
const int LOOP_PERIOD = 100;

ZStateEstimator z_state_estimator;

void setup() {
  Serial.begin(115200);

  adc.init();

  Serial.println("Searching for LTR-329");

  if (!ltr.begin()) {
    Serial.println("Couldn't find LTR sensor!");
    while (1) delay(10);
  }

  Serial.println("Found LTR sensor!");

  ltr.setGain(LTR3XX_GAIN_2);
  ltr.setIntegrationTime(LTR3XX_INTEGTIME_100);
  ltr.setMeasurementRate(LTR3XX_MEASRATE_200);

  z_state_estimator.init();
}

void loop() {
  uint16_t visible_plus_ir, infrared;
  unsigned long currentTime = millis();
  bool valid = false;

  if (currentTime - lastTime > LOOP_PERIOD) {

    // timing update
    lastTime = currentTime;

    // ADC update
    adc.updateSample();
    latestADC = adc.printSample();

    // light sensor update
    if (ltr.newDataAvailable()) {
      valid = ltr.readBothChannels(visible_plus_ir, infrared);
    }

    // pressure → depth
    z_state_estimator.updateState(analogRead(PRESSURE_PIN));
     depth = z_state_estimator.state;

    // print ADC
    Serial.print("ADC: ");
    Serial.print(latestADC);

    // print depth
    Serial.print("\tDepth: ");
    Serial.print(depth);

    // print light sensor
    if (valid) {
      Serial.print("\t\tCH0 Visible + IR: ");
      Serial.print(visible_plus_ir);
      Serial.print("\t\tCH1 Infrared: ");
      Serial.println(infrared);
    } 
    else {
      Serial.print("\t\tCH0 Visible + IR: NO DATA");
      Serial.println("\t\tCH1 IR: NO DATA");
    }
  }
}