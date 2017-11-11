
include <_setup.scad>;
include <frame.scad>;
use <standoff.scad>;

SIDE_ANGLE = atan(
	(ESC_DIM[1] - FC_DIM[1]) / 2
	/
	((ESC_POS[2] + ESC_DIM[2] / 2 - CANOPY_ROUNDING / 2) - CANOPY_ROUNDING));

$fs = 0.5;

// print two
*
rotate([0, 90])
esc_standoff();

*
frame_bottom();

*
frame_top();

// print four
*
rotate([0, 90])
frame_standoff();

// print two
*
//scale([-1, 1]) // ... and two of these
propeller(
	blade_dim = [12, 0.8],
	n = 5,
	pitch = 30,
	r = PROP_RAD - TOLERANCE_CLEAR,
	hub_height = MOTOR_SHAFT_HEIGHT,
//	reverse = true,
	shaft_rad = MOTOR_SHAFT_RAD + TOLERANCE_FIT,
	shaft_surround = 1.5,
	support = PRINT_NOZZLE);

*
rotate([-(90 - SIDE_ANGLE), 0])
usb_plug_hole_cover();
