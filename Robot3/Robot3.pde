#include <AFMotor.h>
#include <PololuQTRSensors.h>

AF_DCMotor motor1(1, MOTOR12_64KHZ); // create motor #2, 64KHz pwm
AF_DCMotor motor2(2, MOTOR12_64KHZ); // create motor #2, 64KHz pwm
const int qtrPin = 19; // pin 5 as digital is pin 19
const int buzzerPin = 14;

unsigned long tCnt = 0;
unsigned long tStart = 0;
unsigned long tDelta = 0;
unsigned long tTurn;

unsigned int degree = 0;
unsigned int MAX_DEGREE = 1000;

const int STATE_FORWARD = 1;
const int STATE_TURN_RIGHT = 2;
const int STATE_BACKWARD = 3;
const int STATE_TURN_LEFT = 4;
int state;
int lastState;

// create an object for your type of sensor (RC or Analog)
// in this example there is one sensor on qtrPin
PololuQTRSensorsRC qtr(( unsigned char[]) {qtrPin}, 1);

void setup() {
  Serial.begin(9600);           // set up Serial library at 9600 bps  
  motor1.setSpeed(255);     // set the speed to 200/255
  motor2.setSpeed(255);     // set the speed to 200/255
  pinMode(buzzerPin, OUTPUT);
  tStart = millis();
  lastState = state = STATE_FORWARD;
  state = 0;
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

  if(a[0] > 900 ) {
      state = STATE_FORWARD;
      degree = 0;
      MAX_DEGREE = 1000;
  } else if (a[0] < 100 ) {
    degree += tDelta;
    if( degree > MAX_DEGREE ) {
      degree = 0;
      if( state != STATE_TURN_RIGHT ) {
        state = STATE_TURN_RIGHT;
      } else {
        if( MAX_DEGREE == 1000 ) {
          MAX_DEGREE = 2000;
        }
        state = STATE_TURN_LEFT;
      }
    }
  }
  
   if( state == 0 ) {
     moveRobot();
     return;
   }
   
//     state = STATE_BACKWARD;
//     state = STATE_TURN_RIGHT;   
   moveRobot();
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

void moveRobot() {
    
   if( state != lastState ) {
      motor1.run(RELEASE);      // stopped
      motor2.run(RELEASE);      // stopped
   }
   
   switch( state ) {
     default: return; // helps test, state 0 = dont move.
     case STATE_FORWARD: {
       motor1.run(FORWARD);      // turn it on going forward
       motor2.run(FORWARD);      // turn it on going forward
       break;
     }
     case STATE_BACKWARD: {
       motor1.run(BACKWARD);      // turn it on going backward
       motor2.run(BACKWARD);      // turn it on going backward
       break;
     }
     case STATE_TURN_RIGHT: {
       motor1.run(FORWARD);      // turn it on going forward
       motor2.run(BACKWARD);      // turn it on going backward
       break;
     }
     case STATE_TURN_LEFT: {
       motor2.run(FORWARD);      // turn it on going forward
       motor1.run(BACKWARD);      // turn it on going backward
       break;
     }
   }
   lastState = state;
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


