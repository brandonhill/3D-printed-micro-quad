
include <_setup.scad>;

module post(
		l,
		r = POST_RAD,
		screw_dim = FRAME_SCREW_DIM,
		n = 6,
	) {

	difference() {
		cylinder(h = l, r = r, center = true, $fn = n);
		cylinder(h = l + 0.2, r = screw_dim[0] / 2, center = true);
	}
}
