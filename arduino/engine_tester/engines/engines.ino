//motors
#define motorLeftPower 5
#define motorLeftDirection 7
#define motorRightPower 6
#define motorRightDirection 8

const int defMotorRightSpeed = 200;
const int defMotorLeftSpeed = 200;
int motorLeftSpeed;
int motorRightSpeed;




void setup() {
  Serial.begin(9600);

  pinMode(motorLeftDirection, OUTPUT);
  pinMode(motorLeftPower, OUTPUT);
  pinMode(motorRightDirection, OUTPUT);
  pinMode(motorRightPower, OUTPUT);
}

void loop() {

  go(200, 200);

}


void go(int speedLeft, int speedRight) {
  digitalWrite(motorLeftDirection, HIGH);
  analogWrite(motorLeftPower, speedRight);
  digitalWrite(motorRightDirection, HIGH);
  analogWrite(motorRightPower, speedLeft);
}
