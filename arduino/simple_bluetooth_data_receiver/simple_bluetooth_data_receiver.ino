#include<SoftwareSerial.h>

/* Create object named bt of the class SoftwareSerial */
SoftwareSerial bt(2, 3); /* (Rx,Tx) */
String x = "";
bool b = false;

void setup() {
  bt.begin(9600); /* Define baud rate for software serial communication */
  Serial.begin(9600); /* Define baud rate for serial communication */
}

void loop() {
  while (bt.available()) /* If data is available on serial port */
  {
    // if not .write, it would print out just bytes instead of String
    Serial.println((char)bt.read()); /* Print character received on to the serial monitor */

  }
}
