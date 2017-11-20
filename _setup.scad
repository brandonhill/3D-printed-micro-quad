
include <_conf.scad>;

module diff_batt(
		batt_dim = BATT_DIM,
		batt_pos = BATT_POS,
		tolerance = TOLERANCE_CLEAR,
	) {

	// battery cutout (extends beyond back side)
	translate(batt_pos)
	translate([-batt_dim[0] / 2, 0])
	rotate([0, 90])
	cylinder(h = (batt_dim[0] + tolerance) * 2, r = batt_dim[2] / 2 + tolerance, center = true);
}

module diff_fc() {
	pos_fc()
	fc_teeny_f4(tolerance = TOLERANCE_FIT)
	children();
}

module diff_power_wires(
		length = POWER_WIRE_ANCHOR_LENGTH,
		power_wire_rad = POWER_WIRE_RAD,
	) {

	pos_power_wires()
	cylinder(h = length * 2 + 0.2, r = power_wire_rad + TOLERANCE_CLOSE, center = true);
}

module pos_batt_wire(
		batt_dim = BATT_DIM,
		batt_pos = BATT_POS,
		batt_wire_rad = BATT_WIRE_RAD,
	) {

	pos_wires()
	hull()
	for (x = [-batt_wire_rad, batt_wire_rad])
	translate([x, 0])
	children();
}

module pos_cam_mount(pos = CAM_MOUNT_POS, z) {
	position(pos, [], z)
	children();
}

module pos_esc(pos = ESC_POS, rot = ESC_ROT, z) {
	position(pos, rot, z)
	children();
}

module pos_fc(pos = FC_POS, rot = FC_ROT, z) {
	position(pos, rot, z)
	children();
}

module pos_stack_mount_screws(
		board_dim = FC_BOARD_DIM,
		spacing = FC_HOLE_SPACING,
		z = FRAME_BASE_THICKNESS,
	) {
	pos_fc(z = z)
	transpose(spacing / 2)
	children();
}

module pos_motor() {
	reflect()
	translate([MOTOR_POS[0], MOTOR_POS[1]] / 2)
	children();
}

module pos_motor_screws(hull = false, n = 3) {
	rotate([0, 0, 90 - BOOM_ANGLE])
	for (a = [0 : (360 / n) : 360])
		rotate([0, 0, a])
		hull()
		for (x = [0 : (hull ? 1 : 0)])
		translate([MOTOR_MOUNT_RAD * (hull ? x : 1), 0])
		children();
}

module pos_motors(scale = true, z = MOTOR_POS[2]) {
	for (x = [-1, 1], y = [-1, 1])
		scale([scale ? x : 1, scale ? y : 1])
		translate([SIZE[0] / 2 * (scale ? 1 : x), SIZE[1] / 2 * (scale ? 1 : y), z])
		children();
}

module pos_power_wires(
		batt_dim = BATT_DIM,
		batt_pos = BATT_POS,
		batt_wire_rad = BATT_WIRE_RAD,
		canopy_thickness = CANOPY_THICKNESS,
		power_wire_rad = POWER_WIRE_RAD,
	) {

	pos_wires()
	translate([batt_wire_rad * 2 + canopy_thickness, 0])
	for (i = [0 : 1])
	translate([power_wire_rad + power_wire_rad * 2 * i, 0]) // no tolerance here, want it tight
	children();
}

module pos_props(pos = PROP_POS, rot = PROP_ROT) {
	reflect()
	position(pos, rot)
	children();
}

module pos_rx(pos = RX_POS, rot = RX_ROT, z) {
	position(pos, rot, z)
	children();
}

module pos_vtx(pos = VTX_POS, rot = VTX_ROT, z) {
	position(pos, rot, z)
	children();
}

module pos_wires(
		batt_dim = BATT_DIM,
		batt_pos = BATT_POS,
	) {

	translate([batt_pos[0] - batt_dim[0] / 2, 0, batt_pos[2] - batt_dim[2] / 2])
	rotate([0, 90])
	children();
}

module position(pos, rot, z) {
	translate([0, 0, z != undef ? -pos[2] + z : 0])
	translate(pos)
	rotate(rot)
	children();
}

module shape_usb_plug(dim = USB_PLUG_DIM) {
	square(dim, true);
}
