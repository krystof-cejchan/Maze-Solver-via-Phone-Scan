#include <ArduinoQueue.h>

//deklarace motory
#define mLv 5 //motor levý - výkon
#define mLs 7 //motor levý - směr
#define mPv 6 //motor pravý - výkon
#define mPs 8 //motor pravý - směr


//deklarace promennych pro hodnoty
int hMin[4];
int hMax[4];
float hNorm[4];
int hodnotaAkt;


// P I D regulace
int korekce;
int mL;
int mP;
// rychlosti
const int vP = 200;
const int vL = 200;
const int P = 100;
const int I = 0;
const int vahy[4] = { -4, -1, 1, 4};
float sumaVH;
float sumaH;
float err;
long iSuma;

const ArduinoQueue<RobotInstruction> instructions();

void setup() {
  Serial.begin(9600);
  //motory
  pinMode(mLs, OUTPUT);
  pinMode(mLv, OUTPUT);
  pinMode(mPs, OUTPUT);
  pinMode(mPv, OUTPUT);

  for (int i = 0; i < 4; i++) {
    pinMode(A0 + i, INPUT);
    hMin[i] = 1023;
    hMax[i] = 0;
  }
  delay(5000);

  jed(0, 150);
  long t0 = millis();
  while ((millis() - t0) < 10000) {
    for (int i = 0; i < 4; i++) {
      int hodnotaCidla = analogRead(A0 + i);
      if (hodnotaCidla < hMin[i]) {
        hMin[i] = hodnotaCidla;
      }
      else if (hodnotaCidla > hMax[i]) {
        hMax[i] = hodnotaCidla;
      }
    }
  }
  zastav();

  delay(3000);
}

void loop() {
  ctiSenzory();

  if (isCrossroad()) {
    zastav();
  }

  sumaVH = 0;
  sumaH = 0;
  for (int i = 0; i < 4; i++) {
    sumaVH += (hNorm[i] * vahy[i]);
    sumaH += hNorm[i];
  }
  err = sumaVH / sumaH;
  korekce = int(P * err);

  iSuma += err;

  if ((iSuma * err) < -10)
    iSuma = 0;

  korekce = int((P * err) + (I * iSuma));

  mL = constrain(vL - korekce, 0, 255);
  mP = constrain(vP + korekce, 0, 255);

  jed(mL, mP);
}
/**
   uloží hodnoty ze senzorů do pole
*/
void ctiSenzory()   {
  for (int i = 0; i < 4; i++) {
    hodnotaAkt = analogRead(A0 + i);
    hNorm[i] = int((100.0 * (1.0 * (hodnotaAkt - hMin[i]))) / (1.0 * (hMax[i] - hMin[i]))); //čtení hodnot z čidel
    hNorm[i] = constrain(hNorm[i], 0, 100);
  }
}

bool isCrossroad() {
  return (hNorm[0] > hMin[0] - 40 && hNorm[3] > hMin[3] - 40);
}
/**
   nastaví rychlost motorů dopředu
   @param rychlostL rychlost levého motoru
   @param rychlostP rychlost pravého motoru
*/
void jed(int rychlostL, int rychlostP) {
  digitalWrite(mLs, LOW);
  analogWrite(mLv, rychlostP);
  digitalWrite(mPs, LOW);
  analogWrite(mPv, rychlostL);
}
/**
   zastaví motory
*/
void zastav() {
  digitalWrite(mLs, LOW);
  analogWrite(mLv, 0);
  digitalWrite(mPs, LOW);
  analogWrite(mPv, 0);
}

class RobotInstruction {

};
