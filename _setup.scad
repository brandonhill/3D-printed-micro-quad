
include <_conf.scad>;

module pos_motor_screws(n = 3) {
	rotate([0, 0, 90 - MOTOR_ANGLE])
	for (a = [0 : (360 / n) : 360])
		rotate([0, 0, a])
		translate([MOTOR_MOUNT_RAD, 0])
		children();
}

module pos_motor() {
	reflect()
	translate([MOTOR_POS[0], MOTOR_POS[1]] / 2)
	children();
}

module pos_motors(z = 0, scale = true) {
	for (x = [-1, 1], y = [-1, 1])
		scale([scale ? x : 1, scale ? y : 1])
		translate([SIZE[0] / 2 * (scale ? 1 : x), SIZE[1] / 2 * (scale ? 1 : y), z])
		children();
}
