#include<SoftwareSerial.h>
#include <ArduinoQueue.h>

//motors
#define motorLeftPower 5
#define motorLeftDirection 7
#define motorRightPower 6
#define motorRightDirection 8

SoftwareSerial bt(2, 3); /* (Rx,Tx) */

//declaration of variables and constants
int minValues[4];
int maxValues[4];
float normalizedValues[4];
int currentValue;


// P I D regulation
const int P = 100;
const int I = 0;
float calculatedError;
int correction;


// speeeed!
const int defMotorRightSpeed = 200;
const int defMotorLeftSpeed = 200;
int motorLeftSpeed;
int motorRightSpeed;

int weight[4] = { -3, -1, 1, 3};
float sumWeightedValues;
float sumValues;
long sumOfI;
const int boostedWeight = 12;

enum dir {LEFT, RIGHT, PASS};

ArduinoQueue<dir> directions;

// given that input is in the following pattern:
//  {RobotInstruction.X1, RobotInstruction.X2, .  .  ., RobotInstruction.Xn}
ArduinoQueue<dir> acceptInput(String rawInput) {
  dir accaptable[3] = {PASS, LEFT, RIGHT};
  ArduinoQueue<dir> dirs = ArduinoQueue<dir>();
  for (int i = 0; i < rawInput.length(); i++) {
    switch (rawInput.charAt(i)) {
      case 'P': dirs.enqueue(PASS); break;
      case 'L': dirs.enqueue(LEFT); break;
      case 'R': dirs.enqueue(RIGHT); break;
    }
  }
  return dirs;
}

void setup() {
  bt.begin(9600);
  Serial.begin(9600);

  while (directions.isEmpty()) {
    if (bt.available())
    {
      String data;
      data = bt.read();
      directions = acceptInput(data);
    }
  }
  //motory
  pinMode(motorLeftDirection, OUTPUT);
  pinMode(motorLeftPower, OUTPUT);
  pinMode(motorRightDirection, OUTPUT);
  pinMode(motorRightPower, OUTPUT);

  for (int i = 0; i < 4; i++) {
    pinMode(A0 + i, INPUT);
    minValues[i] = 1023;
    maxValues[i] = 0;
  }
  delay(3000);

  go(0, 150);
  long t0 = millis();
  while ((millis() - t0) < 5000) {
    for (int i = 0; i < 4; i++) {
      int currSensorReadValue = analogRead(A0 + i);
      if (currSensorReadValue < minValues[i]) {
        minValues[i] = currSensorReadValue;
      }
      if (currSensorReadValue > maxValues[i]) {
        maxValues[i] = currSensorReadValue;
      }
    }
  }
  stopRobot();

  delay(3000);
}

void loop() {


  // vem prvni instrukci z queue
  //  je-li to pass, nic neměň; ale kotroluj zda neni křižovatka
  //  je-li to left/right, uprav hodnoty vah a kotroluj zda neni křižovatka
  //až bude křižovatka tak začni znovu od prvnní instrukce
  dir currDir = directions.getHead();
  switch (currDir) {
    case RIGHT:
      weight[3] = boostedWeight;      break;
    case LEFT:
      weight[0] = boostedWeight;      break;
    default:
      weight[0] = -3; weight[3] = 3;      break;
  }

  readSensors();

  calcDeviation();

  motorLeftSpeed = constrain(defMotorLeftSpeed - correction, 0, 255);
  motorRightSpeed = constrain(defMotorRightSpeed + correction, 0, 255);

  go(motorLeftSpeed, motorRightSpeed);

  if (isCrossroad(currDir)) {
    directions.dequeue();
  }
}


/**
   saves sensor-read values to an array
*/
void readSensors()   {
  for (int i = 0; i < 4; i++)
    normalizedValues[i] = constrain(normValue(i), 0, 100);
}

// calculates deviation
void calcDeviation() {
  sumWeightedValues = 0;
  sumValues = 0;
  for (int i = 0; i < 4; i++) {
    sumWeightedValues += (normalizedValues[i] * weight[i]);
    sumValues += normalizedValues[i];
  }
  calculatedError = sumWeightedValues / sumValues;
  correction = int(P * calculatedError);
}
boolean isCrossroad(dir currDir) {
  const byte m = 100;
  byte d  = currDir == LEFT ? 0 : 3;
  bool isCurrBlack = constrain(normValue(d), 0, m) > 50;
  if (currDir == PASS && !isCurrBlack)
    return constrain(normValue(0), 0, m) > 50;

  return isCurrBlack;
}

void go(int speedLeft, int speedRight) {
  digitalWrite(motorLeftDirection, HIGH);
  analogWrite(motorLeftPower, speedRight);
  digitalWrite(motorRightDirection, HIGH);
  analogWrite(motorRightPower, speedLeft);
}

void stopRobot() {
  digitalWrite(motorLeftDirection, LOW);
  analogWrite(motorLeftPower, 0);
  digitalWrite(motorRightDirection, LOW);
  analogWrite(motorRightPower, 0);
}

int normValue(byte i) {
  return int((100.0 * (1.0 * (analogRead(A0 + i) - minValues[i]))) / (1.0 * (maxValues[i] - minValues[i])));
}
