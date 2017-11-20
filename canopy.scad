
include <_setup.scad>;
use <frame.scad>;

module canopy(
		cam_angle = CAM_ANGLE,
		cam_cutout_rad = CAM_CUTOUT_RAD,
		cam_dim = CAM_DIM,
		cam_pos = CAM_MOUNT_POS,
		cam_mount_height = CAM_MOUNT_HEIGHT,
		canopy_thickness = CANOPY_THICKNESS,
		clearance = COMPONENT_CLEARANCE,
		frame_flange_width = FRAME_FLANGE_WIDTH,
		walls = FRAME_WALLS,
		vtx_dim = VTX_DIM,
		vtx_pos = VTX_POS,
	) {

	frame_width = frame_flange_width + walls;

	difference() {
		canopy_solid();

		// cavity
		translate([0, 0, -0.05])
		canopy_solid(offset = -canopy_thickness);

		// cam cutout
		translate([cam_pos[0], 0, cam_pos[2] + cam_mount_height + cam_dim[1] / 2])
		rotate([0, -cam_angle])
		translate([clearance, 0])
		capsule(h = cam_dim[1], r = cam_cutout_rad, center = true);

		// motor wires
		linear_extrude(frame_width)
		shape_frame_booms(width = frame_width + walls * 2);

		// power/VTx ant. wires hole
		hull()
		translate([0, -2])
		reflect(x = false, z = true)
		translate([
			vtx_pos[0] - vtx_dim[1] / 2 - clearance - walls / 2,
			2,
			vtx_pos[2] + vtx_dim[2] / 2])
		rotate([0, 90])
		cylinder(h = walls * 3, r = walls, center = true);
	}
}

module canopy_solid(
		cam_angle = CAM_ANGLE,
		cam_dim = CAM_DIM,
		cam_mount_height = CAM_MOUNT_HEIGHT,
		cam_pos = CAM_MOUNT_POS,
		clearance = COMPONENT_CLEARANCE,
		offset = 0,
		walls = FRAME_WALLS,
	) {

	height = cam_pos[2] + cam_mount_height + cam_dim[1] * cos(cam_angle);

	linear_extrude(height / 2, convexity = 2)
	offset(r = -(walls + TOLERANCE_FIT) + offset)
	shape_frame_center();

	translate([0, 0, height / 2])
	linear_extrude(height / 2 + offset, scale = 0.85, convexity = 2)
	offset(r = -(walls + TOLERANCE_FIT) + offset)
	shape_frame_center();
}
