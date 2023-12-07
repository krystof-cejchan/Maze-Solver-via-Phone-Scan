//motors
#define motorLeftPower 7
#define motorLeftDirection 5
#define motorRightPower 8
#define motorRightDirection 6
 int i = 100, j= 100;

void setup() {
  Serial.begin(9600);
  pinMode(motorLeftDirection, OUTPUT);
  pinMode(motorLeftPower, OUTPUT);
  pinMode(motorRightDirection, OUTPUT);
  pinMode(motorRightPower, OUTPUT);
}

void loop() {
  delay(70);
if(i>160){
  i=100;
  j=100;
  }
  go(i++ , j++);

  Serial.println(String(i)+" | "+String(j));

}


void go(int speedLeft, int speedRight) {
  digitalWrite(motorLeftDirection, HIGH);
  analogWrite(motorLeftPower, speedRight);
  digitalWrite(motorRightDirection, HIGH);
  analogWrite(motorRightPower, speedLeft);
}
