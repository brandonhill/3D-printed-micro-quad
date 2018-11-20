
include <_setup.scad>;
include <frame.scad>;
use <camera mount.scad>;
use <canopy.scad>;

PRINT_COL = "white";
PRINT_ALPHA = 1;

print(["CG = ", CG, ", Weight (components) ≈ ", WEIGHT]);

*
cg();

translate([0, 0, 0.1])
mock_battery();

*mock_buzzer();

camera_mount()
mock_camera();

mock_esc();

mock_fc();

// experimenting
*translate([-38, 0, 15])
rotate([0, -90])
5g_cp_antenna(5);

// inspections
//show_half() // internals
{

	color(PRINT_COL, PRINT_ALPHA)
	translate([0, 0, FRAME_BASE_THICKNESS + TOLERANCE_FIT])
	canopy();

	color(PRINT_COL, PRINT_ALPHA)
	frame();

	pos_motors()
	rotate([0, 0, -BOOM_ANGLE])
	mock_motor();

	pos_props()
	mock_prop();
}

mock_rx();

mock_vtx();

// size check
*
#translate([0, 0, -1])
cube([SIZE[0], SIZE[1], 1], true);

// ****************************************************************************

module cg() {
	translate(CG) {
		color("red")
		rotate([0, 90])
		cylinder(h = SIZE_DIA * 2, r = 0.25, center = true);

		color("lime")
		rotate([90, 0])
		cylinder(h = SIZE_DIA * 2, r = 0.25, center = true);

		color("blue")
		cylinder(h = SIZE_DIA * 2, r = 0.25, center = true);
	}
}

module mock_battery(pos = BATT_POS, rot = BATTERY_ROT) {
	translate(pos)
	rotate(rot)
	color(COLOUR_GREY_DARK)
	cube(BATT_DIM, center = true);
}

module mock_buzzer(pos = BUZZER_POS, rot = BUZZER_ROT) {
	translate(pos)
	rotate(rot)
	buzzer_piezo(h = BUZZER_DIM[2], r = BUZZER_DIM[0] / 2, wires = false);
}

module mock_camera() {

	fov_inset = 4; // back it into the lens
	fov_cone_height = SIZE[0] * 0.2;

//	translate(CAM_MOUNT_POS)
//	rotate(CAM_ROT)
	{

		cam_cmos_micro();

		// FOV
		*
		% translate([CAM_DIM[2] / 2 - fov_inset, 0])
		rotate([0, 90])
		cylinder(h = fov_cone_height, r1 = 0, r2 = tan(CAM_FOV / 2) * fov_cone_height);
	}
}

module mock_esc(pos = ESC_POS, rot = ESC_ROT) {
	translate(pos)
	rotate(rot)
	esc_teeny_6a_4in1();
}

module mock_fc() {
	pos_fc()
	fc_teeny_f4();
}

module mock_motor(pos = [], rot = MOTOR_ROT) {
	translate(pos)
	rotate(rot)
	motor_sunnysky_0705();
}

module mock_prop(pos = [], rot = []) {
	translate(pos)
	rotate(rot)
// 	cylinder(h = 1, r = PROP_DIM[0] / 2); // disc
	color(COLOUR_BLACK)
	rotate_extrude()
	translate([PROP_RAD, 0])
	circle(0.1);
}

module mock_rx(pos = RX_POS, rot = RX_ROT) {
	translate(pos)
	rotate(rot)
	color(COLOUR_GREY_DARK)
	cube(RX_DIM, true);
}

module mock_vtx(pos = VTX_POS, rot = VTX_ROT) {
	translate(pos)
	rotate(rot)
	vtx_vtx03();
}
