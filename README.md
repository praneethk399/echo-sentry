# EchoSentinel — Arduino Ultrasonic Radar System

A servo-swept HC-SR04 ultrasonic sensor paired with a live green radar
display (Processing), inspired by classic sonar sweep UIs. The Arduino
sweeps the sensor across an arc, measures distance at each step, and
streams the readings over serial; the companion Processing app renders
range rings, bearing lines, a moving sweep beam, and fading blips for
anything detected — basically a desktop sonar scope.

## How it works

1. **Arduino** (`arduino/EchoSentinel.ino`) sweeps an SG90 servo from
   15° to 165° and back. At each step it fires the HC-SR04, measures
   echo time, converts it to centimeters, and prints `angle,distance.`
   over serial at 115200 baud.
2. **Processing** (`processing/EchoSentinel_Display.pde`) listens on
   the serial port, parses each reading, and draws it on a radar-style
   display: concentric range rings, a sweeping beam synced to the
   servo angle, and glowing blips that fade out over ~3 seconds.
3. **Mount** (`cad/mount.scad`) is a parametric OpenSCAD model for a
   3D-printable base that cradles the servo and holds the HC-SR04 on
   an arm above it, so the sensor sweeps cleanly without cable snag.

## Hardware

| Part | Notes |
|---|---|
| Arduino Uno/Nano (or compatible) | Any board with a hardware serial + `Servo` support |
| HC-SR04 ultrasonic sensor | TRIG -> D9, ECHO -> D10 |
| SG90 (or similar) micro servo | Signal -> D11 |
| Jumper wires, breadboard | — |
| 3D-printed mount (optional) | See `cad/mount.scad` |

Power both the HC-SR04 and servo from 5V, with a shared ground. If the
servo draws enough current to brown out the board, power it from a
separate 5V source and tie the grounds together.

## Setup

1. Wire the HC-SR04 and servo as above.
2. Open `arduino/EchoSentinel.ino` in the Arduino IDE, select your
   board/port, upload.
3. Open `processing/EchoSentinel_Display.pde` in the Processing IDE.
4. Set `PRINT_PORTS = true`, run once, check the console for your
   Arduino's serial port, note its index or name.
5. Set `SERIAL_PORT_INDEX` (or `SERIAL_PORT_NAME`) accordingly,
   set `PRINT_PORTS = false`, run again.
6. Close the Arduino IDE's Serial Monitor first — only one program can
   hold the serial port at a time.

## Repo layout

```
EchoSentinel/
├── arduino/
│   └── EchoSentinel.ino
├── processing/
│   └── EchoSentinel_Display.pde
├── cad/
│   └── mount.scad
└── README.md
```

## Tuning

- `SWEEP_MIN_DEG` / `SWEEP_MAX_DEG` (Arduino) — limit the physical
  sweep arc if your servo horn or mount can't reach a full 15–165°.
- `STEP_DELAY_MS` (Arduino) — lower for a faster sweep, raise if
  readings get noisy.
- `MAX_RANGE_CM` (Processing) — should match your expected max
  detection range; sets the outer radar ring.
