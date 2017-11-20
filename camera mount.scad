
include <_setup.scad>;

module camera_mount(
		angle = CAM_ANGLE,
		pitch = CAM_MOUNT_SCREW_PITCH,
		clip_rad = CAM_CLIP_RAD,
		clip_thickness = CAM_CLIP_THICKNESS,
		clip_width = CAM_CLIP_WIDTH,
		height = CAM_MOUNT_HEIGHT,
		screw_dim = CAM_MOUNT_SCREW_DIM,
		surround = CAM_MOUNT_SCREW_SURROUND,
	) {

	clip_cutout_angle = 135;

	module clip() {
		pos()
		linear_extrude(clip_width)
		shape_clip();
	}

	module diff_clip() {
		pos()
		linear_extrude(20, center = true)
		circle(r = clip_rad + TOLERANCE_CLOSE);
	}

	module pos() {
		translate([-(screw_dim[0] + surround * 2), 0, height + clip_rad])
		rotate([0, 90 - angle])
		children();
	}

	module shape_clip() {
		rotate([0, 0, 180])
		difference() {
			circle(r = clip_rad + TOLERANCE_CLOSE + clip_thickness);
			circle(r = clip_rad + TOLERANCE_CLOSE);
			rotate([0, 0, -clip_cutout_angle / 2])
			segment(clip_cutout_angle, clip_rad * 2);
		}
	}

	module surround() {
		screw_surround(
			dim = screw_dim,
			h = height,
			walls = surround + TOLERANCE_FIT);
	}

	pos_cam_mount() {
		difference() {
			union() {

				clip();

				difference() {
					hull() {
						intersection() {
							translate([0, 0, height / 2])
							surround();

							clip();
						}
						surround();
					}

					diff_clip();
				}

				surround();
			}

			translate([0, 0, -1])
			scale([1, 1, -1])
			screw_diff(
				dim = screw_dim,
				h = height,
				pitch = pitch,
				tolerance = TOLERANCE_FIT);
		}

		pos()
		rotate([0, -90])
		children();
	}
}
