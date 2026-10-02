// EchoSentinel — Servo/HC-SR04 Radar Mount
// Parametric OpenSCAD design. Open in OpenSCAD (openscad.org), tweak
// the parameters below, render (F6), export to STL for printing.

// ---- Parameters ----
base_w = 70;
base_d = 70;
base_h = 4;

servo_body_w = 23;
servo_body_d = 12.5;
servo_body_h = 22;
servo_wall = 2;

sensor_w = 45;
sensor_h = 20;
sensor_hole_spacing_x = 36;
sensor_hole_spacing_y = 15;
sensor_mount_h = 35;      // height of sensor arm above servo horn
arm_thickness = 4;

mount_hole_d = 2.6;       // M2.5 self-tap

// ---- Base plate with mounting holes ----
module base_plate() {
  difference() {
    cube([base_w, base_d, base_h], center = true);
    for (x = [-1, 1]) {
      for (y = [-1, 1]) {
        translate([x * (base_w/2 - 6), y * (base_d/2 - 6), 0])
          cylinder(h = base_h * 3, d = mount_hole_d, center = true, $fn = 24);
      }
    }
  }
}

// ---- Servo cradle (SG90-size) ----
module servo_cradle() {
  translate([0, 0, base_h/2])
    difference() {
      cube([servo_body_w + servo_wall*2, servo_body_d + servo_wall*2, servo_body_h],
           center = false);
      translate([servo_wall, servo_wall, -1])
        cube([servo_body_w, servo_body_d, servo_body_h + 2]);
    }
}

// ---- Sensor arm that attaches to the servo horn and holds the HC-SR04 ----
module sensor_arm() {
  translate([0, 0, base_h/2 + servo_body_h])
    union() {
      // vertical riser
      cube([arm_thickness, servo_body_d, sensor_mount_h], center = false);

      // horizontal sensor plate at top
      translate([-(sensor_w - arm_thickness)/2, 0, sensor_mount_h])
        difference() {
          cube([sensor_w, sensor_h, arm_thickness]);
          translate([(sensor_w - sensor_hole_spacing_x)/2,
                     (sensor_h - sensor_hole_spacing_y)/2, -1])
            cylinder(h = arm_thickness + 2, d = mount_hole_d, $fn = 24);
          translate([(sensor_w - sensor_hole_spacing_x)/2 + sensor_hole_spacing_x,
                     (sensor_h - sensor_hole_spacing_y)/2, -1])
            cylinder(h = arm_thickness + 2, d = mount_hole_d, $fn = 24);
          translate([(sensor_w - sensor_hole_spacing_x)/2,
                     (sensor_h - sensor_hole_spacing_y)/2 + sensor_hole_spacing_y, -1])
            cylinder(h = arm_thickness + 2, d = mount_hole_d, $fn = 24);
          translate([(sensor_w - sensor_hole_spacing_x)/2 + sensor_hole_spacing_x,
                     (sensor_h - sensor_hole_spacing_y)/2 + sensor_hole_spacing_y, -1])
            cylinder(h = arm_thickness + 2, d = mount_hole_d, $fn = 24);
        }
    }
}

module echo_sentinel_mount() {
  base_plate();
  translate([-(servo_body_w + servo_wall*2)/2, -(servo_body_d + servo_wall*2)/2, 0])
    servo_cradle();
  translate([0, -servo_body_d/2, 0])
    sensor_arm();
}

echo_sentinel_mount();
