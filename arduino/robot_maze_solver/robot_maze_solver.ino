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

String inputText = "";

int weight[4] = { -3, -1, 1, 3};
float sumWeightedValues;
float sumValues;

enum dir {
  LEFT,
  RIGHT,
  PASS,
  END
};

dir currDir;

ArduinoQueue<dir> directions = ArduinoQueue<dir>();

// given that input is in the following pattern:
//  {X1, X2, .  .  ., Xn}
void acceptInput(char rawInput) {
  Serial.println(rawInput);
  inputText += rawInput;
  switch (rawInput) {
    case 'P':
      directions.enqueue(PASS);
      break;
    case 'L':
      directions.enqueue(LEFT);
      break;
    case 'R':
      directions.enqueue(RIGHT);
      break;
  }
}

void setup() {
  bt.begin(9600);
  Serial.begin(9600);

  while (inputText.lastIndexOf('"') < 1) {
    while (bt.available()) {
      acceptInput((char)bt.read());
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
  if (isCrossroad()) {
    stopRobot();
    delay(400);
    handleCrossroad();
    stopRobot();
  }
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
  if ((currDir == END || directions.itemCount() <= 1) && allSensorsBlack()) return true;

  const byte m = 100,
             d = (currDir == LEFT ? 3 : 0);
  bool isCurrBlack = constrain(normValue(d), 0, m) > 50;
  if (currDir == PASS)
    return constrain(normValue(3), 0, m) > 50;

  return isCurrBlack;
}

boolean allSensorsBlack() {
  for (int i = 0; i < 4; i++) {
    if (constrain(normValue(i), 0, 100) <= 50) return false;
  }
  return true;
}


/**
   dequeues queue with directions
   and turns robot according to @param d
*/
void handleCrossroad() {
  if ((currDir == END || directions.itemCount() <= 1) && allSensorsBlack()) {
    go(140, 140);
    delay(1000);
    while (true) {
      stopRobot();
    }
  }

  if (currDir == RIGHT) {
    go(150, 0);
    delay(1200);
  }

  else if (currDir == LEFT) {
    go(0, 150);
    delay(1200);
  }
  else if (currDir == PASS) {
    while (constrain(normValue(0), 0, 100) > 50 || constrain(normValue(3), 0, 100) > 50) {
      readSensors();
      int correction = calcDeviationCorrection();
      motorLeftSpeed = constrain(defMotorLeftSpeed - correction, 0, 150);
      motorRightSpeed = constrain(defMotorRightSpeed + correction, 0, 150);
      go(motorLeftSpeed, motorRightSpeed);
    }
  }

  currDir = !directions.isEmpty() ? directions.dequeue() : END;
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
