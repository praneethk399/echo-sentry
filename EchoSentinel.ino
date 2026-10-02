/*
  EchoSentinel — Arduino Ultrasonic Radar System
  -----------------------------------------------
  Sweeps an HC-SR04 ultrasonic sensor mounted on an SG90 servo across
  a configurable arc, measures distance at each angle, and streams
  "angle,distance." lines over serial for the companion Processing
  display (processing/EchoSentinel_Display.pde) to render as a radar
  sweep.

  Wiring:
    HC-SR04  TRIG -> D9
    HC-SR04  ECHO -> D10
    Servo    signal -> D11
    Servo + HC-SR04 VCC -> 5V, GND -> GND
    (If using a separate servo power rail, tie grounds together.)
*/

#include <Servo.h>

const uint8_t TRIG_PIN = 9;
const uint8_t ECHO_PIN = 10;
const uint8_t SERVO_PIN = 11;

const int SWEEP_MIN_DEG = 15;
const int SWEEP_MAX_DEG = 165;
const int SWEEP_STEP_DEG = 1;
const int STEP_DELAY_MS = 20;      // time between angle steps
const unsigned long ECHO_TIMEOUT_US = 25000UL; // ~4.3 m max range cutoff
const float MAX_VALID_CM = 400.0f; // HC-SR04 practical max range

Servo sweepServo;
int currentAngle = SWEEP_MIN_DEG;
int direction = 1;

float readDistanceCm() {
  digitalWrite(TRIG_PIN, LOW);
  delayMicroseconds(2);
  digitalWrite(TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);

  unsigned long duration = pulseIn(ECHO_PIN, HIGH, ECHO_TIMEOUT_US);
  if (duration == 0) {
    return -1.0f; // no echo / out of range
  }

  float distanceCm = duration * 0.0343f / 2.0f;
  if (distanceCm <= 0 || distanceCm > MAX_VALID_CM) {
    return -1.0f;
  }
  return distanceCm;
}

void setup() {
  Serial.begin(115200);
  pinMode(TRIG_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);
  digitalWrite(TRIG_PIN, LOW);

  sweepServo.attach(SERVO_PIN);
  sweepServo.write(currentAngle);
  delay(500); // let servo settle at start position
}

void loop() {
  sweepServo.write(currentAngle);
  delay(STEP_DELAY_MS);

  float distanceCm = readDistanceCm();

  Serial.print(currentAngle);
  Serial.print(',');
  if (distanceCm < 0) {
    Serial.print("0"); // 0 = no valid reading at this angle
  } else {
    Serial.print(distanceCm, 1);
  }
  Serial.print('.');
  Serial.println();

  currentAngle += direction * SWEEP_STEP_DEG;
  if (currentAngle >= SWEEP_MAX_DEG) {
    currentAngle = SWEEP_MAX_DEG;
    direction = -1;
  } else if (currentAngle <= SWEEP_MIN_DEG) {
    currentAngle = SWEEP_MIN_DEG;
    direction = 1;
  }
}
