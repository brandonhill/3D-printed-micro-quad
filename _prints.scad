
include <_setup.scad>;
include <camera mount.scad>;
include <canopy.scad>;
include <frame.scad>;

MOTOR_SHAFT_HEIGHT = MOTOR_SUNNYSKY_0705_SHAFT_HEIGHT;
MOTOR_SHAFT_RAD = MOTOR_SUNNYSKY_0705_SHAFT_RAD;

$fs = 0.5;

*
camera_mount();

*
rotate([180, 0, 0])
canopy();

*
frame();

// print two
//*
//scale([-1, 1]) // ... and two of these
propeller(
	blade_dim = [12, 0.8],
	n = 3,
	pitch = 30,
	r = PROP_RAD - TOLERANCE_CLEAR,
	hub_height = MOTOR_SHAFT_HEIGHT,
//	reverse = true,
	shaft_rad = MOTOR_SHAFT_RAD + TOLERANCE_FIT,
	shaft_surround = 1.5,
	support = PRINT_NOZZLE_DIA);
