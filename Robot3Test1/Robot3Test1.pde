#include <PololuQTRSensors.h>

const int qtrPin = 19; // pin 5 as digital is pin 19
const int buzzerPin = 14;

unsigned long tCnt = 0;
unsigned long tStart = 0;
unsigned long tDelta = 0;
unsigned long tTurn;

// create an object for your type of sensor (RC or Analog)
// in this example there is one sensor on qtrPin
PololuQTRSensorsRC qtr(( unsigned char[]) {qtrPin}, 1);

void setup() {
  Serial.begin(9600);           // set up Serial library at 9600 bps  
  pinMode(buzzerPin, OUTPUT);
  tStart = millis();
  buzz(buzzerPin, 1000, 100);
  calibrateQTR();
  buzz(buzzerPin, 2000, 200);
}

void loop() {
  delay(250);
  tDelta = millis() - tStart;
  tCnt += tDelta;
  tStart += tDelta;
  
  unsigned int a[] = { 0 };
  qtr.readCalibrated(a);
  Serial.println(a[0]);
  buzz(buzzerPin, a[0] - 50, 100);
}

void calibrateQTR() {
  // start calibration phase and move the sensors over both
  // reflectance extremes they will encounter in your application:
  int i;
  for (i = 0; i < 250; i++) {
    qtr.calibrate();
    delay(50);
  }
}

void buzz(int targetPin, long frequency, long length) {
  long delayValue = 1000000/frequency/2; // calculate the delay value between transitions
  // 1 second's worth of microseconds, divided by the frequency, then split in half since
  // there are two phases to each cycle
  long numCycles = frequency * length/ 1000; // calculate the number of cycles for proper timing
  // multiply frequency, which is really cycles per second, by the number of seconds to 
  // get the total number of cycles to produce
 for (long i=0; i < numCycles; i++){ // for the calculated length of time...
    digitalWrite(targetPin,HIGH); // write the buzzer pin high to push out the diaphram
    delayMicroseconds(delayValue); // wait for the calculated delay value
    digitalWrite(targetPin,LOW); // write the buzzer pin low to pull back the diaphram
    delayMicroseconds(delayValue); // wait againf or the calculated delay value
  }
}


