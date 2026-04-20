#ifndef __LIGHTSENSOR_h__
#define __LIGHTSENSOR_h__

#include <Arduino.h>
#include "DataSource.h"
#include "Adafruit_LTR329_LTR303.h"
#include "Pinouts.h"

/*
 * LightSensor implements SD logging for the onboard pushbutton 
 */


class LightSensor : public DataSource
{
public:
  LightSensor(void);

  void init(void);

  // Managing state
  uint16_t ch0;
  uint16_t ch1;

  void updateState(void);
  String printState(void);
  Adafruit_LTR329 ltr = Adafruit_LTR329();

  // Write out
  size_t writeDataBytes(unsigned char * buffer, size_t idx);

  int lastExecutionTime = -1;

private:
 bool ltr_enabled = false;
 bool valid = false;
  
  
};

#endif