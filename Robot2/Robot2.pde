#include <AFMotor.h>
#include <ServoTimer1.h>

AF_DCMotor motor1(1, MOTOR12_64KHZ); // create motor #2, 64KHz pwm
AF_DCMotor motor2(2, MOTOR12_64KHZ); // create motor #2, 64KHz pwm
ServoTimer1 myservo;  // create servo object to control a servo 
const int irPin = 19; // pin 5 as digital is pin 19
const int lightPin = 3;

unsigned long tCnt = 0;
unsigned long tStart = 0;
unsigned long tDelta = 0;
unsigned long tTurn;
unsigned long tRotate;

const int rForward = 85;
const int rBackward = 95;
const int rStop = 0;

const int STATE_FORWARD = 1;
const int STATE_TURN_RIGHT = 2;
const int STATE_BACKWARD = 3;
int state;
int lastState;
int rotateState;

boolean waitLight;
boolean waitDark;

void setup() {
  Serial.begin(9600);           // set up Serial library at 9600 bps  
  myservo.attach(10);  // attaches the servo on pin 10 
  pinMode(irPin, INPUT);     
  pinMode(lightPin, INPUT);     
  motor1.setSpeed(255);     // set the speed to 200/255
  motor2.setSpeed(255);     // set the speed to 200/255
  tStart = millis();
  lastState = state = STATE_FORWARD;
  rotateState = rForward;
  tRotate = 500; // .75 seconds to turn
  state = 0;
  waitDark = true;
  waitLight = false;
}

void loop() {
   tDelta = millis() - tStart;
   tCnt += tDelta;
   tStart += tDelta;

   int r = analogRead(lightPin);
   if( r > 900 && waitDark) {
     if( rotateState == rForward) {
       rotateState = rBackward;
     } else {
       rotateState = rForward;
     }
     waitDark = false;
     waitLight = true;
   } else if ( r < 900 && waitLight ) {
     waitDark = true;
     waitLight = false;
   }
   
   if( state == 0 ) {
     moveRobot();
     return;
   }
   
   // set state
   if( digitalRead(irPin) == 0 ) {
     state = STATE_BACKWARD;
   } else {
     if( state == STATE_BACKWARD ) {
       state = STATE_TURN_RIGHT;
       tTurn = 1500; // turn for 1.5 seconds
     } else if ( state == STATE_TURN_RIGHT) {
       tTurn -= tDelta;
       if( tTurn <= 0 ) {
         state = STATE_FORWARD;
       }
     } else {
     state = STATE_FORWARD;
     }
   }
   
   moveRobot();
}

void moveRobot() {
 
   myservo.write(rotateState); 
   
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
       motor1.run(BACKWARD);      // turn it on going forward
       motor2.run(BACKWARD);      // turn it on going forward
       break;
     }
     case STATE_TURN_RIGHT: {
       motor1.run(FORWARD);      // turn it on going forward
       motor2.run(BACKWARD);      // turn it on going forward
       break;
     }
   }
   lastState = state;
}

