/*
  EchoSentinel — Radar Display
  -----------------------------
  Reads "angle,distance." lines from the Arduino over serial and
  renders a classic green sweeping radar display: range rings,
  bearing lines, a moving sweep line, and fading blips for detected
  objects.

  Set SERIAL_PORT_INDEX below (or SERIAL_PORT_NAME) to match your
  Arduino's port. Run once with PRINT_PORTS = true to list ports in
  the console.
*/

import processing.serial.*;

Serial myPort;
final boolean PRINT_PORTS = false;
final int SERIAL_PORT_INDEX = 0;     // index into Serial.list()
final String SERIAL_PORT_NAME = "";  // leave "" to use index instead

final int MAX_RANGE_CM = 400;
final int SWEEP_MIN_DEG = 15;
final int SWEEP_MAX_DEG = 165;

int currentAngle = 90;
float currentDistance = 0;

ArrayList<Blip> blips = new ArrayList<Blip>();

color bgColor, ringColor, sweepColor, textColor;

void setup() {
  size(1000, 650);
  bgColor = color(5, 20, 5);
  ringColor = color(30, 160, 30);
  sweepColor = color(60, 255, 60);
  textColor = color(60, 255, 60);

  if (PRINT_PORTS) {
    println(Serial.list());
  }

  String portName = SERIAL_PORT_NAME.length() > 0
    ? SERIAL_PORT_NAME
    : Serial.list()[SERIAL_PORT_INDEX];
  myPort = new Serial(this, portName, 115200);
  myPort.bufferUntil('.');

  textFont(createFont("Courier New Bold", 16));
}

void draw() {
  background(bgColor);
  translate(width / 2, height - 60);

  drawGrid();
  drawSweepLine();
  drawBlips();
  drawHUD();
}

void drawGrid() {
  noFill();
  stroke(ringColor);
  strokeWeight(1);

  float maxR = min(width / 2 - 40, height - 120);
  for (int i = 1; i <= 4; i++) {
    float r = maxR * i / 4.0;
    arc(0, 0, r * 2, r * 2, PI, TWO_PI);
  }

  for (int a = 0; a <= 180; a += 30) {
    float rad = radians(180 - a);
    line(0, 0, maxR * cos(rad), -maxR * sin(rad));
  }

  line(-maxR, 0, maxR, 0);
}

void drawSweepLine() {
  float maxR = min(width / 2 - 40, height - 120);
  float rad = radians(180 - currentAngle);
  stroke(sweepColor);
  strokeWeight(3);
  line(0, 0, maxR * cos(rad), -maxR * sin(rad));

  noStroke();
  fill(sweepColor, 40);
  float sweepWidth = radians(4);
  beginShape();
  vertex(0, 0);
  for (float a = rad - sweepWidth; a <= rad + sweepWidth; a += 0.05) {
    vertex(maxR * cos(a), -maxR * sin(a));
  }
  endShape(CLOSE);
}

void drawBlips() {
  float maxR = min(width / 2 - 40, height - 120);
  for (int i = blips.size() - 1; i >= 0; i--) {
    Blip b = blips.get(i);
    float rNorm = constrain(b.distanceCm / MAX_RANGE_CM, 0, 1);
    float r = rNorm * maxR;
    float rad = radians(180 - b.angleDeg);
    float x = r * cos(rad);
    float y = -r * sin(rad);

    float age = (millis() - b.timestamp) / 3000.0;
    float alpha = map(constrain(age, 0, 1), 0, 1, 255, 0);

    noStroke();
    fill(sweepColor, alpha);
    ellipse(x, y, 8, 8);

    if (age >= 1.0) {
      blips.remove(i);
    }
  }
}

void drawHUD() {
  fill(textColor);
  noStroke();
  textAlign(LEFT);
  text("EchoSentinel RADAR", -width / 2 + 20, -height + 130);
  text("Angle: " + currentAngle + "°", -width / 2 + 20, -height + 160);
  text("Range: " + (currentDistance > 0 ? nf(currentDistance, 0, 1) + " cm" : "---"),
       -width / 2 + 20, -height + 185);
}

void serialEvent(Serial p) {
  String raw = p.readStringUntil('.');
  if (raw == null) return;
  raw = trim(raw.replace(".", ""));
  if (raw.length() == 0) return;

  String[] parts = split(raw, ',');
  if (parts.length != 2) return;

  try {
    int angle = int(parts[0]);
    float distance = float(parts[1]);

    currentAngle = constrain(angle, SWEEP_MIN_DEG, SWEEP_MAX_DEG);
    currentDistance = distance;

    if (distance > 0) {
      blips.add(new Blip(angle, distance, millis()));
    }
  } catch (Exception e) {
    // malformed line, skip
  }
}

class Blip {
  int angleDeg;
  float distanceCm;
  long timestamp;

  Blip(int a, float d, long t) {
    angleDeg = a;
    distanceCm = d;
    timestamp = t;
  }
}
