#include "LightSensor.h"
#include "Printer.h"

extern Printer printer;

LightSensor::LightSensor(void) 
  : DataSource("ch0,ch1", "uint16,uint16") // from DataSource
{}


void LightSensor::init(void)
{
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
}


void LightSensor::updateState(void)
// This function is called in the main loop of Default_Robot.ino
{
  if (ltr.newDataAvailable()) {
    valid = ltr.readBothChannels(ch0, ch1);
  }

}


String LightSensor::printState(void)
// This function returns a string that the Printer class 
// can print to the serial monitor if desired
{
  if (valid){
    return "Ch0 " + String(ch0) + "Ch1" + String(ch1);
  }
  else{
    return ":( NOOOOOO";
  }
}

size_t LightSensor::writeDataBytes(unsigned char * buffer, size_t idx)
// This function writes data to the micro SD card
{
  uint16_t * data_slot = (uint16_t *) &buffer[idx];
  data_slot[0] = ch0;
  data_slot[1] = ch1;
  return idx + 2 * sizeof(uint16_t);
}
