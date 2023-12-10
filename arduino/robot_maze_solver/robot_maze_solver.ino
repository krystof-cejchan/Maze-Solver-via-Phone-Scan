#include<SoftwareSerial.h>

#include <ArduinoQueue.h>

//motors
#define motorLeftPower 6
#define motorLeftDirection 8
#define motorRightPower 5
#define motorRightDirection 7

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
long sumOfI;

// speeeed!
const int defMotorRightSpeed = 130;
const int defMotorLeftSpeed = 130;
int motorLeftSpeed;
int motorRightSpeed;

bool lastCrossroad = false;

int weight[4] = { -3, -1, 1, 3};
float sumWeightedValues;
float sumValues;

enum dir {
  LEFT,
  RIGHT,
  PASS
};

dir currDir;

ArduinoQueue < dir > directions = ArduinoQueue < dir > ();

// given that input is in the following pattern:
//  {X1, X2, .  .  ., Xn}
void acceptInput(String rawInput) {
  for (int i = 0; i < rawInput.length(); i++) {
    switch (rawInput.charAt(i)) {
      case 'P':
        directions.enqueue(PASS);
        break;
      case 'L':
        directions.enqueue(LEFT);
        break;
      case 'R':
        directions.enqueue(RIGHT);
        break;
      default:
        continue;
    }
  }
}

void setup() {
  delay(2000);
  bt.begin(9600);
  Serial.begin(9600);

  /* while (directions.isEmpty()) {
     if (bt.available())
     {
       String data;
       data = bt.read();
       directions = acceptInput(data);
     }
    }*/
  acceptInput("LR");
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

  currDir = directions.dequeue();
  stopRobot();
  delay(3000);
}

void loop() {
  readSensors();

  int correction = calcDeviationCorrection();

  motorLeftSpeed = constrain(defMotorLeftSpeed - correction, 0, 150);
  motorRightSpeed = constrain(defMotorRightSpeed + correction, 0, 150);

  go(motorLeftSpeed, motorRightSpeed);
  if (not lastCrossroad) {
    if (lastCrossroad = isCrossroad()) {
      stopRobot();
      delay(400);
      handleCrossroad();
      stopRobot();
    }
  } else lastCrossroad = isNoCrossroad();

}

/**
   saves sensor-read values to an array
*/
void readSensors() {
  for (int i = 0; i < 4; i++)
    normalizedValues[i] = constrain(normValue(i), 0, 100);
}

// calculates deviation
int calcDeviationCorrection() {
  sumWeightedValues = 0;
  sumValues = 0;
  for (int i = 0; i < 4; i++) {
    sumWeightedValues += (normalizedValues[i] * weight[i]);
    sumValues += normalizedValues[i];
  }
  calculatedError = sumWeightedValues / sumValues;
  sumOfI += calculatedError;
  if (sumOfI * calculatedError < -10)
    sumOfI = 0;
  return int(P * calculatedError + I * sumOfI);

}

boolean isCrossroad() {
  const byte m = 100,
             d = currDir == LEFT ? 3 : 0;
  bool isCurrBlack = constrain(normValue(d), 0, m) > 50;
  if (currDir == PASS && !isCurrBlack)
    return constrain(normValue(3), 0, m) > 50;

  return isCurrBlack;
}

boolean isNoCrossroad() {
  return !(constrain(normValue(0), 0, 100) > 50 && constrain(normValue(3), 0, 100) > 50);
}

/**
   dequeues queue with directions
   and turns robot according to @param d
*/
void handleCrossroad() {
  if (currDir == RIGHT)
    go(150, 0);

  else if (currDir == LEFT)
    go(0, 150);

  delay(900);
  currDir = !directions.isEmpty() ? directions.dequeue() : PASS;
}

void go(int speedLeft, int speedRight) {
  digitalWrite(motorLeftDirection, LOW);
  analogWrite(motorLeftPower, speedLeft);
  digitalWrite(motorRightDirection, LOW);
  analogWrite(motorRightPower, speedRight);
}

void stopRobot() {
  digitalWrite(motorLeftDirection, LOW);
  analogWrite(motorLeftPower, 0);
  digitalWrite(motorRightDirection, LOW);
  analogWrite(motorRightPower, 0);
}

const int normValue(const byte i) {
  return int((100.0 * (1.0 * (analogRead(A0 + i) - minValues[i]))) / (1.0 * (maxValues[i] - minValues[i])));
}
