
include <_setup.scad>;

module shape_frame_booms(
		boom_angle = BOOM_ANGLE,
		flange_width = FRAME_FLANGE_WIDTH,
		prop_guards = PROP_GUARDS,
		size = SIZE,
		size_dia = SIZE_DIA,
		motor_wires_rad = MOTOR_WIRES_RAD,
		thickness = FRAME_WALLS,
	) {
	reflect(x = false)
	rotate([0, 0, 90 - boom_angle]) {
		if (prop_guards)
		square([size[0] * 4, thickness + flange_width], true);
		square([size_dia, (motor_wires_rad + thickness) * 2], true);
	}
}

module shape_frame_center(
		cam_dim = CAM_DIM,
		clearance = COMPONENT_CLEARANCE,
		esc_dim = ESC_DIM,
		fc_dim = FC_DIM,
		offset = 0,
		smoothing = SMOOTHING_FINE,
		thickness = FRAME_WALLS,
		rx_dim = RX_DIM,
		vtx_dim = VTX_DIM,
	) {

	cam_offset = -cam_dim[2] / 2 + clearance * 2;

	smooth_acute(smoothing)
	offset(r = clearance + thickness + TOLERANCE_FIT + thickness + offset) {
		hull() {
			pos_fc(z = 0)
			square([fc_dim[0], fc_dim[1]], true);

			pos_esc(z = 0)
			square([esc_dim[0], esc_dim[1]], true);
		}

		hull() {
			pos_cam_mount(z = 0)
			translate([cam_offset, 0])
			square([cam_dim[2], cam_dim[0]], true);

			pos_rx(z = 0)
			square([rx_dim[0], rx_dim[1]], true);
		}

		hull() {
			pos_rx(z = 0)
			square([rx_dim[0], rx_dim[1]], true);

			pos_vtx(z = 0)
			square([vtx_dim[0], vtx_dim[1]], true);
		}

		hull() {
			pos_cam_mount(z = 0)
			translate([cam_offset, 0])
			square([cam_dim[2], cam_dim[0]], true);

			pos_vtx(z = 0)
			square([vtx_dim[0], vtx_dim[1]], true);
		}
	}
}

module shape_frame_inner(
		flange_width = FRAME_FLANGE_WIDTH,
		motor_mount_arm_width = MOTOR_MOUNT_ARM_WIDTH,
		prop_guards = PROP_GUARDS,
		size = SIZE,
		smoothing = SMOOTHING_FINE,
		walls = FRAME_WALLS,
	) {

	smooth_acute(smoothing) {
		shape_frame_center();
		shape_frame_booms();
		shape_frame_motor_mounts();
	}
}

module shape_frame_motor_mounts(
		hull = true,
		motor_mount_arm_width = MOTOR_MOUNT_ARM_WIDTH,
		mount_rad = MOTOR_MOUNT_RAD,
		walls = FRAME_WALLS,
		wire_clearance = true,
	) {

	r = motor_mount_arm_width / 2 + TOLERANCE_CLEAR + walls;

	pos_motors(z = false) {
		if (hull)
			hull()
			pos_motor_screws()
			circle(r);
		else
			pos_motor_screws()
			circle(r);

		if (wire_clearance)
		rotate([0, 0, 180])
		segment(120, mount_rad + r);
	}
}

module shape_frame_outer(
		inset_factor = FRAME_INSET_FACTOR,
		r_prop = PROP_RAD,
		prop_clearance = PROP_CLEARANCE,
		prop_guards = PROP_GUARDS,
		size = SIZE,
		size_outer = SIZE_OUTER,
		smoothing = SMOOTHING_COARSE,
		walls = FRAME_WALLS,
		flange_width = FRAME_FLANGE_WIDTH,
	) {


	smooth_acute(smoothing) {
		reflect()
		translate(size / 2)
		circle(r_prop + prop_clearance + flange_width + walls);

		// VTx antenna protection
		translate([-size_outer[0] / 4 + flange_width, 0])
		square([size_outer[0] / 2, size[1]], true);

		// inset
		square([size_outer[0] * (1 - inset_factor), size[1]], true);
		square([size[0], size_outer[1] * (1 - inset_factor)], true);
	}
}

module frame(
		base_thickness = FRAME_BASE_THICKNESS,
		cam_dim = CAM_DIM,
		cam_pos = CAM_MOUNT_POS,
		cam_screw_dim = CAM_MOUNT_SCREW_DIM,
		flange_thickness = FRAME_FLANGE_THICKNESS,
		flange_width = FRAME_FLANGE_WIDTH,
		motor_axle_rad = MOTOR_AXLE_RAD,
		motor_screw_dim = MOTOR_SCREW_DIM,
		motor_mount_thickness = MOTOR_MOUNT_THICKNESS,
		prop_guards = PROP_GUARDS,
		stack_hole_spacing = FC_HOLE_SPACING,
		stack_pos = ESC_POS,
		stack_screw_dim = FC_SCREW_DIM,
		stack_screw_pitch = FC_SCREW_PITCH,
		stack_screw_surround = FC_SCREW_SURROUND,
		height = FRAME_HEIGHT,
		smoothing = SMOOTHING_FINE,
		walls = FRAME_WALLS,
	) {

	difference() {
		union() {

			// base
			linear_extrude(base_thickness)
			shape_frame_inner();

			// cam mount reinforcement
			pos_cam_mount(z = 0)
			cylinder(h = flange_thickness, r = cam_screw_dim[0] / 2 + TOLERANCE_CLEAR + flange_width + walls);

			// flange
			linear_extrude(flange_thickness)
			difference() {
				if (prop_guards)
				shape_frame_outer();

				smooth(smoothing)
				difference() {
					if (prop_guards)
					offset(r = -(walls + flange_width))
					shape_frame_outer();

					union() {
						shape_frame_booms();
						shape_frame_inner();
					}
				}

				offset(r = -walls)
				shape_frame_center();
			}

			// motor mounts
			linear_extrude(motor_mount_thickness)
			shape_frame_motor_mounts(hull = false, walls = 0, wire_clearance = false);

			pos_stack_mount_screws()
			screw_surround(
				dim = stack_screw_dim,
				h = stack_pos[2] - base_thickness,
				pitch = stack_screw_pitch,
				tolerance = TOLERANCE_FIT,
				walls = stack_screw_surround);

			// ridges
			linear_extrude(height, convexity = 2)
			intersection() {
				hull()
				shape_frame_outer();

				union() {

					// booms - outer
					difference() {
						shape_frame_booms(flange_width = 0);
						hull()
						shape_frame_motor_mounts();
					}

					// interior
					difference() {
						shape_frame_inner();
						offset(r = -walls)
						shape_frame_inner();
					}

					// perimeter
					if (prop_guards)
					difference() {
						shape_frame_outer();
						offset(r = -walls)
						shape_frame_outer();
					}
				}
			}
		}

		// cam mount hole
		pos_cam_mount(z = -0.1)
		cylinder(h = height, r = cam_screw_dim[0] / 2 + TOLERANCE_CLEAR);

		// motor axle/screw holes
		pos_motors(z = -0.1) {
			pos_motor_screws()
			cylinder(h = height, r = motor_screw_dim[0] / 2 + TOLERANCE_CLEAR);
			cylinder(h = height, r = motor_axle_rad + TOLERANCE_CLEAR);
		}

		// stack mount holes (through base)
		pos_stack_mount_screws(z = -0.1)
		cylinder(h = base_thickness + 0.2, r = stack_screw_dim[0] / 2);
	}
}
