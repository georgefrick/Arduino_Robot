#include <AFMotor.h>

AF_DCMotor motor1(1, MOTOR12_64KHZ); // create motor #2, 64KHz pwm
AF_DCMotor motor2(2, MOTOR12_64KHZ); // create motor #2, 64KHz pwm

unsigned long tCnt = 0;
unsigned long tStart = 0;
unsigned long tDelta = 0;

void setup() {
  Serial.begin(9600);           // set up Serial library at 9600 bps  
  motor1.setSpeed(255);     // set the speed to 200/255
  motor2.setSpeed(255);     // set the speed to 200/255
  tStart = millis();
}

void loop() {
   tDelta = millis() - tStart;
   tCnt += tDelta;
   tStart += tDelta;
   // run motors for 5 seconds.
   if( tCnt <= 5000) {
   motor1.run(FORWARD);      // turn it on going forward
   motor2.run(BACKWARD);      // turn it on going forward
      return;
   } else if ( tCnt <= 6300 ) {
   motor1.run(BACKWARD);      // turn it on going forward
   motor2.run(BACKWARD);      // turn it on going forward
      return;
   } else if ( tCnt <= 11300 ) {
   motor1.run(FORWARD);      // turn it on going forward
   motor2.run(BACKWARD);      // turn it on going forward
      return;
   } else if ( tCnt <= 12600 ) {
   motor1.run(FORWARD);      // turn it on going forward
   motor2.run(FORWARD);      // turn it on going forward
      return;
   } 
      motor1.run(RELEASE);      // stopped
      motor2.run(RELEASE);      // stopped
}
