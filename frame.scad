
include <_setup.scad>;
use <_mock.scad>;

BATT_RET_LIP_WIDTH = 2;

module canopy_solid(
		back_pos = FRAME_BACK_POS,
		batt_dim = BATT_DIM,
		batt_pos = BATT_POS,
		batt_ret_lip_width = BATT_RET_LIP_WIDTH,
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
		screw_length = FRAME_SCREW_LENGTH,
		screw_surround = FRAME_SCREW_SURROUND,
		size = SIZE,
		thickness = CANOPY_THICKNESS,
		vtx_dim = VTX_DIM,
		vtx_pos = VTX_POS,
	) {

	r = rounding + offset;

	module front(batt_ret = false) {

		// battery retention lip
		if (batt_ret)
		translate(batt_pos)
		translate([(batt_dim[0] - batt_ret_lip_width) / 2, 0])
		rotate([0, 90])
		cylinder(h = batt_ret_lip_width, r = batt_dim[2] / 2 + TOLERANCE_CLEAR + thickness + offset);

		// bottom front
		translate([front_pos - rounding / 2, dim[1] / 2 - rounding, rounding])
		sphere(r);

		// camera front
		*translate([cam_pos[0], cam_dim[0] / 2 - rounding, cam_pos[2]])
		rotate([0, -cam_angle])
		translate([-cam_pivot_offset - rounding, 0])
		reflect(x = false, y = false, z = [-1, 1])
		translate([0, 0, cam_dim[1] / 2 - rounding / 2])
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

			// fc
			*translate([fc_pos[0], 0])
			reflect(y = false)
			translate([
				fc_dim[0] / 2 - rounding / 2,
				fc_pos[1] + fc_dim[1] / 2 - rounding / 2,
				fc_pos[2] + fc_dim[2] / 2 - rounding / 2])
			sphere(r);

			// vtx
			*translate([
				vtx_pos[0] - vtx_dim[0] / 2,
				dim[1] / 2 - rounding,
				vtx_pos[2] + vtx_dim[2] / 2 - rounding])
			sphere(r);

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
		pos_frame_screws(posts = false, top = true)
		translate([0, 0, height - frame_thickness])
		canopy_screw_surround();

	if (protrusion_stack) {
		hull()
		union() {
			// esc
			translate([esc_pos[0], esc_pos[1], esc_pos[2] + esc_dim[2] / 2 - rounding / 2])
			reflect()
			translate([esc_dim[0] - rounding, esc_dim[1] - rounding] / 2)
			sphere(r);

			// fc
			translate([fc_pos[0], fc_pos[1], rounding])
			reflect()
			translate([fc_dim[0] - rounding, fc_dim[1] - rounding] / 2)
			sphere(r);
		}
	}
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
		frame_thickness = FRAME_THICKNESS,
		screw_dim = FRAME_SCREW_DIM,
		screw_length = FRAME_SCREW_LENGTH,
		screw_surround = FRAME_SCREW_SURROUND,
	) {

	hull() {
		scale([1, 1, -1])
		cylinder(h = 0.1, r = screw_dim[0] / 2 + screw_surround);

		translate([0, 0, -(screw_length - frame_thickness) * 0.5])
		sphere(screw_dim[0] / 2 + screw_surround);

		translate([0, -screw_surround, -(screw_length - frame_thickness) * 1.75])
		sphere(0.01);
	}
}

module diff_batt(
		batt_dim = BATT_DIM,
		batt_pos = BATT_POS,
	) {

	// battery cutout
	translate(batt_pos)
	translate([-batt_dim[0] / 2, 0])
	rotate([0, 90])
	cylinder(h = (batt_dim[0] + TOLERANCE_CLEAR) * 2, r = batt_dim[2] / 2 + TOLERANCE_CLEAR, center = true);
}

module frame(
		batt_dim = BATT_DIM,
		batt_pos = BATT_POS,
		batt_strap_dim = BATT_STRAP_DIM,
		batt_wire_rad = BATT_WIRE_RAD,
		cam_angle = CAM_ANGLE,
		cam_cutout_rad = CAM_CUTOUT_RAD,
		cam_dim = CAM_DIM,
		cam_mount_thickness = CAM_MOUNT_THICKNESS,
		cam_pos = CAM_POS,
		cam_pivot_offset = CAM_PIVOT_OFFSET,
		cam_screw_rad = CAM_SCREW_RAD,
		canopy_dim = CANOPY_DIM,
		fc_dim = FC_DIM,
		fc_pos = FC_POS,
		frame_height = FRAME_HEIGHT,
		frame_thickness = FRAME_THICKNESS,
		prop_guards_btm = true,
		prop_guards_top = true,
		power_wire_rad = POWER_WIRE_RAD,
		rounding = CANOPY_ROUNDING,
		screw_dim = FRAME_SCREW_DIM,
		screw_surround = FRAME_SCREW_SURROUND,
		screw_length = FRAME_SCREW_LENGTH,
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

			intersection() {
				canopy_solid();

				union() {

					// battery supports
					translate([0, 0, canopy_dim[2] / 2])
					for (x = [
						batt_pos[0] + batt_dim[0] * 0.4,
						vtx_pos[0] - (vtx_dim[0] / 2 - COMPONENT_CLEARANCE * 2)])
					reflect(x = false)
					translate([x, batt_dim[1] / 2])
					cube([canopy_thickness, batt_dim[1] / 4, canopy_dim[2]], true);

					// top side reinforcement
					difference() {
						translate([0, 0, frame_height - frame_thickness + canopy_thickness / 2])
						cube([size[0] * 2, canopy_dim[1], canopy_thickness], true);

						translate([cam_pos[0], 0, frame_height - frame_thickness + canopy_thickness / 2])
						cylinder(h = canopy_thickness * 2, r = canopy_dim[1] / 2 - canopy_thickness, center = true);

						scale([2, 1])
						diff_batt();
					}
				}
			}

			cam_screw_surrounds();

			// screw surrounds
			pos_frame_screws(posts = false, top = true)
			translate([0, 0, frame_height - frame_thickness])
			canopy_screw_surround();
		}

		// cam cutout
		translate([cam_pos[0], 0, cam_pos[2]])
		rotate([0, -cam_angle])
		translate([-cam_pivot_offset, 0])
		capsule(h = cam_dim[1], r = cam_cutout_rad, center = true);

		// cam screw holes
		translate(cam_pos)
		rotate([90, 0]) {
			cylinder(h = canopy_dim[1] * 2, r = cam_screw_rad, center = true);

			reflect(x = 0, y = 0, z = [-1, 1])
			translate([0, 0, cam_dim[0] / 2 + TOLERANCE_CLEAR + cam_mount_thickness])
			cylinder(h = canopy_dim[1] * 2, r = cam_screw_rad * 2);
		}

		// battery cutout
		diff_batt();

		// battery strap hole
		*translate([0, 0, batt_pos[2] - batt_dim[2] / 2 - COMPONENT_CLEARANCE])
		hull()
		reflect(y = false)
		rotate([90, 0])
		translate([batt_strap_dim[0] / 2, 0])
		cylinder(h = size[1] , r = batt_strap_dim[1] / 2, center = true);

		// battery/plug wire holes
		translate([batt_pos[0] - batt_dim[0] / 2, 0, batt_pos[2] - batt_dim[2] / 2])
		rotate([0, 90]) {
			hull()
			for (x = [-batt_wire_rad, batt_wire_rad])
			translate([x, 0])
			cylinder(h = 10, r = batt_wire_rad + TOLERANCE_CLEAR, center = true);
			
			translate([batt_wire_rad * 2 + power_wire_rad, 0])
			cylinder(h = 10, r = power_wire_rad + TOLERANCE_CLOSE, center = true);
			translate([batt_wire_rad * 2 + power_wire_rad * 3, 0])
			cylinder(h = 10, r = power_wire_rad + TOLERANCE_CLOSE, center = true);
		}

		// screw holes
		pos_frame_screws(top = true)
		translate([0, 0, frame_height])
		cylinder(h = screw_length * 2, r = screw_dim[0] / 2, center = true);

		// vtx switch access hole
		*translate([
			vtx_pos[0] - vtx_dim[0] / 2 - 3,
			vtx_pos[1] - vtx_dim[1] * 0.25,
			vtx_pos[2] - vtx_dim[2] * 0.2])
		rotate([0, 90])
		cylinder(h = 10, r = 1.25, center = true);
	}
}

module frame_bottom(
		height = FRAME_HEIGHT,
		motor_wires_hole_rad = MOTOR_WIRES_HOLE_RAD,
		motor_wires_hole_offset = MOTOR_WIRES_HOLE_OFFSET,
		size = SIZE,
		thickness = FRAME_THICKNESS,
	) {

	difference() {
		frame(prop_guards_top = false);

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
	}
}

module frame_top(
		height = FRAME_HEIGHT,
		screw_dim = FRAME_SCREW_DIM,
		size = SIZE,
		thickness = FRAME_THICKNESS,
	) {

	difference() {
		frame(prop_guards_btm = false);

		translate([0, 0, -height * 2 + height - thickness])
		cube([size[0] * 4, size[1] * 4, height * 4], true);
	}
}

module pos_frame_screws(
		batt_dim = BATT_DIM,
		batt_pos = BATT_POS,
		cam_dim = CAM_DIM,
		cam_pos = CAM_POS,
		fc_hole_spacing = FC_OMNIBUS_F3_MINI_HOLE_SPACING,
		fc_pos = FC_POS,
		posts = false,
		prop_rad = PROP_RAD,
		screw_dim = FRAME_SCREW_DIM,
		screw_surround = FRAME_SCREW_SURROUND,
		size = SIZE,
		thickness = CANOPY_THICKNESS,
		top = false,
	) {

	// back screws
	if (top)
	reflect(x = false)
	translate([
		batt_pos[0] - batt_dim[0] / 2 + screw_surround + screw_dim[0] / 2,
		batt_dim[1] / 2 + screw_surround + screw_dim[0] / 2])
	children();

	// front screws
	if (top)
	reflect(x = false)
	translate([
		cam_pos[0],
		cam_dim[0] / 2 + TOLERANCE_CLEAR + screw_surround + screw_dim[0] / 2])
	children();

	// prop guard screws
	if (posts)
	reflect()
	translate(size / 2)
	rotate([0, 0, 90 - MOTOR_ANGLE])
	translate([prop_rad + screw_surround + screw_dim[0] / 2, 0])
	children();
}

module shape_frame_bottom(
		frame_screw_dim = FRAME_SCREW_DIM,
		width = FRAME_WIDTH,
	) {

	difference() {
		shape_frame_outer();

		shape_frame_inner();

		// screw holes
		pos_frame_screws(posts = true)
		circle(frame_screw_dim[0] / 2 + TOLERANCE_CLOSE);
	}
}

module shape_frame_inner(
		canopy_dim = CANOPY_DIM,
		height = FRAME_HEIGHT,
		motor_angle = MOTOR_ANGLE,
		motor_rad = MOTOR_RAD,
		prop_clearance = PROP_CLEARANCE_SIDE,
		prop_rad = PROP_RAD,
		screw_dim = FRAME_SCREW_DIM,
		screw_surround = FRAME_SCREW_SURROUND,
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
					pos_motor_screws()
					circle(screw_dim[0] / 2 + screw_surround);

					rotate([0, 0, -motor_angle]) {
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
			canopy_solid(protrusion_stack = false, protrusion_screws = false);
		
			// perimeter
			difference() {
				square(size * 3, true);
				offset(r = -width)
				shape_frame_outer(top = top);
			}

			// screw surrounds
			pos_frame_screws(posts = true, top = top)
			circle(screw_dim[0] / 2 + screw_surround);
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
		circle(screw_dim[0] / 2 + screw_surround);
	}

	// main prop guard shape
	smooth_acute(rounding_outer)
	shape();

	// reduce smoothing for screw surrounds
	smooth_acute(rounding_inner)
	shape();
}

module shape_frame_top(
		frame_screw_dim = FRAME_SCREW_DIM,
		motor_screw_dim = MOTOR_SCREW_RAD,
	) {

	difference() {
		shape_frame_outer(top = true);

		shape_frame_inner(top = true);

		// frame screw holes
		pos_frame_screws(posts = true, top = true)
		circle(frame_screw_dim[0] / 2 + TOLERANCE_CLOSE);

		// motor screw holes
		pos_motors()
		pos_motor_screws()
		circle(motor_screw_dim[0] / 2 + TOLERANCE_CLOSE);
	}
}
