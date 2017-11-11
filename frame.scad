
include <_setup.scad>;

module battery_supports(
		batt_dim = BATT_DIM,
		batt_pos = BATT_POS,
		canopy_dim = CANOPY_DIM,
		canopy_thickness = CANOPY_THICKNESS,
		vtx_dim = VTX_DIM,
		vtx_pos = VTX_POS,
	) {

	translate([0, 0, canopy_dim[2] / 2])
	for (x = [
		batt_pos[0] + batt_dim[0] * 0.4,
		vtx_pos[0] - (vtx_dim[0] / 2 - COMPONENT_CLEARANCE * 2)])
	reflect(x = false)
	translate([x, batt_dim[1] / 2])
	cube([canopy_thickness, batt_dim[1] / 4, canopy_dim[2]], true);
}

module cam_screw_surrounds(
		cam_dim = CAM_DIM,
		cam_pos = CAM_POS,
		cam_screw_rad = CAM_SCREW_RAD,
		canopy_dim = CANOPY_DIM,
		canopy_thickness = CANOPY_THICKNESS,
		screw_surround = FRAME_SCREW_SURROUND / 2,
		cam_mount_thickness = CAM_MOUNT_THICKNESS,
	) {

	translate(cam_pos)
	reflect(x = false)
// 	translate([0, cam_dim[0] / 2 + TOLERANCE_CLEAR])
	hull()
	rotate([-90, 0]) {
		translate([0, 0, cam_dim[0] / 2 + TOLERANCE_CLEAR])
		cylinder(h = cam_mount_thickness, r = cam_screw_rad + screw_surround);

		translate([0, 5, (canopy_dim[1] - canopy_thickness) / 2])
		cylinder(h = 0.1, r = 0.1);
	}
}

module canopy_screw_surround(
		canopy_thickness = CANOPY_THICKNESS,
		frame_thickness = FRAME_THICKNESS,
		screw_dim = FRAME_SCREW_DIM,
		screw_length = FRAME_SCREW_LENGTH,
		screw_surround = FRAME_SCREW_SURROUND,
	) {

	r = screw_dim[0] / 2 + TOLERANCE_CLOSE + screw_surround;

	hull() {
		scale([1, 1, -1])
		cylinder(h = 0.1, r = r);

		translate([0, 0, -screw_length + r])
		sphere(r);

		translate([0, -screw_surround + canopy_thickness / 2, -screw_length - r])
		sphere(0.01);
	}
}

module canopy_screw_surrounds(
		frame_thickness = FRAME_THICKNESS,
	) {

	pos_frame_screws(posts = false, top = true)
	translate([0, 0, -frame_thickness])
	canopy_screw_surround();
}

module canopy_solid(
		back_pos = FRAME_BACK_POS,
		batt_dim = BATT_DIM,
		batt_pos = BATT_POS,
		cam_angle = CAM_ANGLE,
		cam_dim = CAM_DIM,
		cam_pivot_offset = CAM_PIVOT_OFFSET,
		cam_pos = CAM_POS,
		dim = CANOPY_DIM,
		esc_dim = ESC_DIM,
		esc_pos = ESC_POS,
		esc_rot = ESC_ROT,
		fc_dim = FC_DIM,
		fc_pos = FC_POS,
		frame_thickness = FRAME_THICKNESS,
		front_pos = FRAME_FRONT_POS,
		height = FRAME_HEIGHT,
		offset = 0,
		protrusion_stack = true,
		protrusion_screws = true,
		rounding = CANOPY_ROUNDING,
		screw_dim = FRAME_SCREW_DIM,
		screw_surround = FRAME_SCREW_SURROUND,
		size = SIZE,
		thickness = CANOPY_THICKNESS,
		vtx_dim = VTX_DIM,
		vtx_pos = VTX_POS,
	) {

	r = rounding + offset;

	module front(batt_ret = false) {

		// bottom front
		translate([front_pos - rounding / 2, dim[1] / 2 - rounding, rounding])
		sphere(r);

		// windshield version
		translate([cam_pos[0], cam_dim[0] / 2 - rounding, cam_pos[2]])
		rotate([0, -cam_angle])
		translate([-cam_pivot_offset + offset, 0])
		reflect(x = false, y = false, z = [-1, 1])
		translate([0, 0, cam_dim[1] / 2 - rounding / 2])
		rotate([0, 90])
		scale([1, 1, -1])
		cylinder(h = 0.1, r = r);

		// camera sides
		translate([
			cam_pos[0],
			dim[1] / 2 - rounding,
			height - rounding
			])
		sphere(r);
	}

	hull()
	union() {

		// battery
		translate(batt_pos)
		translate([rounding / 2, 0])
		rotate([0, 90])
		rounded_cylinder(h = batt_dim[0] + rounding + offset * 2, r = batt_dim[2] / 2 + offset, f = r, center = true);

		reflect(x = false) {

			front();

			// back
			translate([back_pos + rounding, dim[1] / 2 - rounding, rounding])
			sphere(r);

			translate([back_pos + rounding, dim[1] / 2 - rounding, height - rounding])
			sphere(r);
		}
	}

	hull()
	reflect(x = false)
	front(batt_ret = true);

	if (protrusion_screws)
		canopy_screw_surrounds();

	if (protrusion_stack) {
		hull()
		union() {

			// top
			translate([fc_pos[0], fc_pos[1], height - frame_thickness - rounding / 2])
			reflect()
			translate([esc_dim[0] - rounding, fc_dim[1] - rounding] / 2)
			sphere(r);

			// ESC
			translate([esc_pos[0], esc_pos[1], esc_pos[2] + esc_dim[2] / 2 - rounding / 2])
			reflect()
			translate([esc_dim[0] - rounding, esc_dim[1] - rounding] / 2)
			sphere(r);

			// FC
			translate([fc_pos[0], fc_pos[1], rounding])
			reflect()
			translate([fc_dim[0] - rounding, fc_dim[1] - rounding] / 2)
			sphere(r);
		}
	}
}

module frame(
		batt_dim = BATT_DIM,
		batt_pos = BATT_POS,
		cam_angle = CAM_ANGLE,
		cam_cutout_rad = CAM_CUTOUT_RAD,
		cam_dim = CAM_DIM,
		cam_pos = CAM_POS,
		cam_pivot_offset = CAM_PIVOT_OFFSET,
		canopy_dim = CANOPY_DIM,
		fc_dim = FC_DIM,
		fc_pos = FC_POS,
		fc_screw_dim = FC_SCREW_DIM,
		frame_height = FRAME_HEIGHT,
		frame_thickness = FRAME_THICKNESS,
		prop_guards_btm = true,
		prop_guards_top = true,
		rounding = CANOPY_ROUNDING,
		screw_dim = FRAME_SCREW_DIM,
		screw_surround = FRAME_SCREW_SURROUND,
		size = SIZE,
		canopy_thickness = CANOPY_THICKNESS,
		vtx_dim = VTX_DIM,
		vtx_pos = VTX_POS,
	) {

	difference() {
		union () {
			difference() {
				union() {
					canopy_solid();

					if (prop_guards_btm)
					linear_extrude(frame_thickness, convexity = 2)
					shape_frame_bottom();

					if (prop_guards_top)
					translate([0, 0, frame_height - frame_thickness])
					linear_extrude(frame_thickness, convexity = 2)
					shape_frame_top();
				}

				// internal cavity
				canopy_solid(offset = -canopy_thickness, protrusion_screws = false);
			}
		}

		// cam cutout
		translate([cam_pos[0], 0, cam_pos[2]])
		rotate([0, -cam_angle])
		translate([-cam_pivot_offset, 0])
		capsule(h = cam_dim[1], r = cam_cutout_rad, center = true);

		// battery cutout
		diff_batt();
	}
}

module frame_bottom(
		batt_dim = BATT_DIM,
		batt_pos = BATT_POS,
		batt_strap_dim = BATT_STRAP_DIM,
		batt_wire_rad = BATT_WIRE_RAD,
		cam_dim = CAM_DIM,
		cam_mount_thickness = CAM_MOUNT_THICKNESS,
		cam_pos = CAM_POS,
		cam_screw_rad = CAM_SCREW_RAD,
		canopy_dim = CANOPY_DIM,
		canopy_thickness = CANOPY_THICKNESS,
		fc_board_dim = FC_BOARD_DIM,
		fc_pos = FC_POS,
		fc_screw_dim = FC_SCREW_DIM,
		fc_screw_pitch = FC_SCREW_PITCH,
		fc_screw_surround = FC_SCREW_SURROUND,
		frame_screw_dim = FRAME_SCREW_DIM,
		frame_screw_length = FRAME_SCREW_LENGTH,
		height = FRAME_HEIGHT,
		motor_wires_hole_rad = MOTOR_WIRES_HOLE_RAD,
		motor_wires_hole_offset = MOTOR_WIRES_HOLE_OFFSET,
		power_wire_rad = POWER_WIRE_RAD,
		size = SIZE,
		thickness = FRAME_THICKNESS,
		vtx_dim = VTX_DIM,
		vtx_pos = VTX_POS,
	) {

	difference() {
		union() {
			frame(prop_guards_top = false);

			cam_screw_surrounds();

			intersection() {
				canopy_solid();

				union() {

					battery_supports();

					canopy_screw_surrounds();

					// FC mounts
					pos_fc_screws()
					translate([0, 0, -fc_pos[2] - fc_board_dim[2]])
					screw_surround(
						dim = fc_screw_dim,
						h = fc_pos[2] - TOLERANCE_CLOSE,
						pitch = fc_screw_pitch,
						tolerance = TOLERANCE_CLOSE,
						walls = fc_screw_surround);

					// wire anchors
					power_wire_anchors();
				}
			}
		}

		// battery cutout
		diff_batt();

		// battery strap hole
		translate([0, 0, batt_pos[2] - batt_dim[2] / 2 - COMPONENT_CLEARANCE])
		hull()
		reflect(y = false)
		rotate([90, 0])
		translate([batt_strap_dim[0] / 2, 0])
		cylinder(h = size[1] , r = batt_strap_dim[1] / 2, center = true);

		// cam screw holes
		translate(cam_pos)
		rotate([90, 0]) {
			cylinder(h = canopy_dim[1] * 2, r = cam_screw_rad, center = true);

			reflect(x = 0, y = 0, z = [-1, 1])
			translate([0, 0, cam_dim[0] / 2 + TOLERANCE_CLEAR + cam_mount_thickness])
			cylinder(h = canopy_dim[1] * 2, r = cam_screw_rad * 2);
		}

		// canopy screw holes
		pos_frame_screws(posts = true, top = true)
		scale([1, 1, -1])
		cylinder(h = frame_screw_length, r = frame_screw_dim[0] / 2 + TOLERANCE_CLOSE);

		// cut top off
		translate([0, 0, height * 2 + height - thickness])
		cube([size[0] * 4, size[1] * 4, height * 4], true);

		// ESC wire holes
		translate([0, 0, height - thickness])
		rotate([90, 0])
		reflect(y = false)
		hull()
		for (y = [-motor_wires_hole_rad, motor_wires_hole_rad])
		translate([motor_wires_hole_offset, y])
		cylinder(h = size[1], r = motor_wires_hole_rad, center = true);

		// FC USB plug cutout
		diff_fc()
		offset(r = TOLERANCE_CLEAR)
		shape_usb_plug();

		// prop guard screw holes
		pos_frame_screws(posts = true)
		translate([0, 0, -0.1])
		cylinder(h = thickness + 0.2, r = frame_screw_dim[0] / 2 + TOLERANCE_CLEAR);

		// wire holes
		pos_batt_wire()
		cylinder(h = 10, r = batt_wire_rad + TOLERANCE_CLEAR, center = true);

		diff_power_wires();
	}
}

module frame_top(
		cam_pos = CAM_POS,
		canopy_dim = CANOPY_DIM,
		canopy_thickness = CANOPY_THICKNESS,
		frame_height = FRAME_HEIGHT,
		motor_axle_clearance_dim = MOTOR_AXLE_CLEARANCE_DIM,
		motor_screw_dim = MOTOR_SCREW_DIM,
		frame_screw_dim = FRAME_SCREW_DIM,
		frame_screw_length = FRAME_SCREW_LENGTH,
		size = SIZE,
		frame_thickness = FRAME_THICKNESS,
	) {

	difference() {
		union() {
			frame(prop_guards_btm = false, protrusion_screws = false);

			intersection() {
				canopy_solid();

				union() {

					battery_supports();

					translate([0, 0, frame_thickness])
					canopy_screw_surrounds();

					// side reinforcement
					difference() {
						translate([-size[0] + cam_pos[0], 0, frame_height - frame_thickness + canopy_thickness / 2])
						cube([size[0] * 2, canopy_dim[1], canopy_thickness], true);

						translate([cam_pos[0], 0, frame_height - frame_thickness + canopy_thickness / 2])
						cylinder(h = canopy_thickness * 2, r = canopy_dim[1] / 2, center = true);
					}
				}
			}
		}

		// battery cutout
		diff_batt();

		// cut off bottom
		translate([0, 0, -frame_height * 2 + frame_height - frame_thickness])
		cube([size[0] * 4, size[1] * 4, frame_height * 4], true);

		// motor axle cutouts
		pos_motors(z = frame_height - frame_thickness) {
			translate([0, 0, -0.1])
			cylinder(h = motor_axle_clearance_dim[1] + 0.1, r = motor_axle_clearance_dim[0] / 2);

			// make print better
			translate([0, 0, motor_axle_clearance_dim[1]])
			cylinder(h = motor_axle_clearance_dim[0] / 4, r1 = motor_axle_clearance_dim[0] / 2, r2 = 0);
		}

		// frame screw holes
		pos_frame_screws(posts = true, top = true)
		scale([1, 1, -1])
		translate([0, 0, -0.1])
		cylinder(h = frame_screw_length + 0.1, r = frame_screw_dim[0] / 2 + TOLERANCE_CLEAR);

		// motor screw holes
		pos_motors()
		pos_motor_screws()
		translate([0, 0, frame_thickness / 2])
		linear_extrude(frame_thickness + 0.2, center = true)
		circle(motor_screw_dim[0] / 2 + TOLERANCE_CLEAR);
	}
}

module power_wire_anchors(
		canopy_thickness = CANOPY_THICKNESS,
		length = POWER_WIRE_ANCHOR_LENGTH,
		power_wire_rad = POWER_WIRE_RAD,
	) {

	r = power_wire_rad + TOLERANCE_CLOSE + canopy_thickness;

	pos_power_wires() {
		linear_extrude(length, convexity = 2)
		difference() {
			circle(r);
			circle(r - canopy_thickness);
		}

		// print support
		linear_extrude(length, convexity = 2, scale = [r / (length + r), 1])
		translate([(length + r) / 2, 0])
		square([length + r, canopy_thickness], true);
	}
}

module shape_frame_bottom() {
	difference() {
		shape_frame_outer();
		shape_frame_inner();
	}
}

module shape_frame_inner(
		canopy_dim = CANOPY_DIM,
		frame_screw_dim = FRAME_SCREW_DIM,
		frame_screw_surround = FRAME_SCREW_SURROUND,
		height = FRAME_HEIGHT,
		BOOM_ANGLE = BOOM_ANGLE,
		motor_rad = MOTOR_RAD,
		motor_screw_dim = MOTOR_SCREW_DIM,
		motor_screw_surround = MOTOR_SCREW_SURROUND,
		prop_clearance = PROP_CLEARANCE_SIDE,
		prop_rad = PROP_RAD,
		size = SIZE,
		rounding = FRAME_INNER_ROUNDING,
		thickness = FRAME_THICKNESS,
		top = false,
		width = FRAME_WIDTH,
	) {

	module shape() {
		difference() {

			offset(r = -width)
			shape_frame_outer(top = top);

			if (top) {
				reflect()
				translate(size / 2) {

					// motor mount
					hull()
					pos_motor_screws()
					circle(motor_screw_dim[0] / 2 + TOLERANCE_CLEAR + motor_screw_surround);

					rotate([0, 0, -BOOM_ANGLE]) {
						// braces
						rotate([0, 0, 90])
						translate([prop_rad, 0])
						square([prop_rad * 2, width], true);

						rotate([0, 0, -90])
						translate([prop_rad, 0])
						square([prop_rad * 2, width * 1.5], true);
					}
				}
			} else {
				square([width, size[1] * 2], true);
			}

			// fuselage
			projection(cut = true)
			translate([0, 0, -(top ? height : 0.1)])
			canopy_solid(protrusion_stack = top, protrusion_screws = false);

			// perimeter
			difference() {
				square(size * 3, true);
				offset(r = -width)
				shape_frame_outer(top = top);
			}

			// screw surrounds
			pos_frame_screws(posts = true, top = top)
			circle(frame_screw_dim[0] / 2 + TOLERANCE_CLEAR + frame_screw_surround);
		}
	}

	difference() {
		smooth(rounding)
		shape();

		square([size[0] * 4, size[1]], true);
	}

	// increase rounding on inner portion to clear curvature of canopy
	intersection() {
		smooth(rounding * (top ? 1.5 : 4))
		shape();

		square([size[0] * 4, size[1]], true);
	}
}

module shape_frame_outer(
		back_pos = FRAME_BACK_POS,
		canopy_dim = CANOPY_DIM,
		frame_screw_dim = FRAME_SCREW_DIM,
		front_pos = FRAME_FRONT_POS,
		height = FRAME_HEIGHT,
		prop_clearance = PROP_CLEARANCE_SIDE,
		prop_rad = PROP_RAD,
		prop_surround_fn = FRAME_PROP_SURROUD_FN,
		rounding_inner = FRAME_INNER_ROUNDING,
		rounding_outer = FRAME_OUTER_ROUNDING,
		screw_dim = FRAME_SCREW_DIM,
		screw_surround = FRAME_SCREW_SURROUND,
		size = SIZE,
		thickness = FRAME_THICKNESS,
		top = false,
		width = FRAME_WIDTH,
	) {

	module shape() {
		// fuselage
		projection(cut = true)
		translate([0, 0, -(top ? height : 0.1)])
		difference() {
			canopy_solid();
			diff_batt();
		}

		// centre
		square(size, true);

		// prop guards
		reflect()
		translate(size / 2)
		circle_true(prop_rad + prop_clearance + width, $fn = prop_surround_fn);

		// screw surrounds
		pos_frame_screws(posts = true, top = top)
		circle(screw_dim[0] / 2 + TOLERANCE_CLEAR + screw_surround);
	}

	// main prop guard shape
	smooth_acute(rounding_outer)
	shape();

	// reduce smoothing for screw surrounds
	smooth_acute(rounding_inner)
	shape();
}

module shape_frame_top() {
	difference() {
		shape_frame_outer(top = true);
		shape_frame_inner(top = true);
	}
}

module usb_plug_hole_cover(
		canopy_thickness = CANOPY_THICKNESS,
		usb_plug_dim = USB_PLUG_DIM,
	) {

	// outer portion (lip)
	intersection() {
		difference() {
			canopy_solid(offset = TOLERANCE_FIT + canopy_thickness);
			canopy_solid(offset = TOLERANCE_FIT);
		}

		diff_fc()
		offset(r = TOLERANCE_CLEAR + canopy_thickness)
		shape_usb_plug();
	}

	// inner portion
	intersection() {
		difference() {
			canopy_solid(offset = TOLERANCE_FIT);
			canopy_solid(offset = TOLERANCE_FIT - canopy_thickness);
		}

		difference() {
			diff_fc()
			offset(r = TOLERANCE_CLEAR - TOLERANCE_FIT)
			shape_usb_plug();

			diff_fc()
			offset(r = -canopy_thickness)
			offset(r = TOLERANCE_CLEAR - TOLERANCE_FIT)
			shape_usb_plug();
		}
	}

	// retainer portion
	intersection() {
		difference() {
			canopy_solid(offset = TOLERANCE_FIT - canopy_thickness);
			canopy_solid(offset = TOLERANCE_FIT - canopy_thickness * 2);
		}

		difference() {
			diff_fc()
			offset(r = TOLERANCE_CLEAR)
			shape_usb_plug();

			diff_fc()
			offset(r = -canopy_thickness)
			offset(r = TOLERANCE_CLEAR - TOLERANCE_FIT)
			shape_usb_plug();
		}
	}
}
