
include <_setup.scad>;

module esc_standoff(
		l = ESC_STANDOFF_LENGTH,
		screw_dim = FC_SCREW_DIM,
		surround = FC_SCREW_SURROUND,
	) {

	standoff(
		l = l,
		screw_dim = screw_dim,
		surround = surround,
		tolerance = TOLERANCE_CLOSE);
}

module frame_standoff(
		l = FRAME_STANDOFF_LENGTH,
		screw_dim = FRAME_SCREW_DIM,
		surround = FRAME_SCREW_SURROUND,
	) {

	standoff(
		l = l,
		screw_dim = screw_dim,
		surround = surround,
		tolerance = 0); // printing flat so no tolerance needed
}

module standoff(
		l,
		screw_dim = FRAME_SCREW_DIM,
		surround = FRAME_SCREW_SURROUND,
		n = 6,
		tolerance = 0,
	) {

	r = screw_dim[0] / 2 + tolerance + surround;

	rotate([0, 0, 360 / n / 2])
	difference() {
		cylinder(h = l, r = r, $fn = n);
		translate([0, 0, -0.1])
		cylinder(h = l + 0.2, r = screw_dim[0] / 2 + tolerance);
	}
}
