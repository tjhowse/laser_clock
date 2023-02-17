
624_od = 13;
624_id = 4;
624_pilot_hole_r = 12.85/2;
include <escapement.scad>

// https://www.thingiverse.com/thing:3575
use <parametric_involute_gear_v5.0.scad>

module gear_pair(shaft_offset, tooth_count_1, tooth_count_2, gear_thickness, bore_diameter_1, bore_diameter_2) {

    circular_pitch = shaft_offset*2 / (tooth_count_1 + tooth_count_2) * 180;

    gear (circular_pitch=circular_pitch,
        number_of_teeth=tooth_count_1,
        gear_thickness = gear_thickness,
        rim_thickness = gear_thickness,
        bore_diameter=bore_diameter_1,
        hub_thickness=gear_thickness);

    // This rotation malarkey is to make the gears mesh properly in the preview.
    translate([shaft_offset,0,0]) rotate([0,0,(360/(2*tooth_count_2))*(tooth_count_2%2-1)])
    gear (circular_pitch=circular_pitch,
        number_of_teeth=tooth_count_2,
        gear_thickness = gear_thickness,
        rim_thickness = gear_thickness,
        bore_diameter=bore_diameter_2,
        hub_thickness=gear_thickness);
}

wt = 4;
shaft_r = 2;
thickness = 2.87;
laser_kerf = 0.3;

hanger_x = ForkWheelDistance/2;
hanger_y = -(ForkWheelDistance/2)*tan(60);

// This is the part that has a bunch of holes in it for hold the parts
// in place.
module frame() {
    holes = [
                [0,0,0], // 0: Escapement wheel
                [ForkWheelDistance,0,0], // 1: Escapement fork
                [hanger_x,hanger_y,0], // 2: Hanger
                [-winch_gear_axis_spacing*cos(winch_gear_angle),-winch_gear_axis_spacing*sin(winch_gear_angle),0], // 3: Winch
    ];
    joins = [
                [1,2], // 0: Escapement wheel
                [0,2], // 1: Escapement fork
                [0,1], // 2: Hanger
                [0,2], // 3: Winch
    ];
    // concat(holes, [0 ,0]);
    difference () {
        for (i = [0:len(holes)-1]) {
            for (j = [0:len(holes)-1]) {
                if (i != j) {
                    if (len(search(j, joins[i])) > 0) {
                        hull() {
                            translate(holes[j]) cylinder(r=wt + shaft_r, h=thickness, $fn=32);
                            translate(holes[i]) cylinder(r=wt + shaft_r, h=thickness, $fn=32);
                        }
                    }
                }
            }
        }
        for (i = [0:len(holes)-1]) {
            translate(holes[i]) cylinder(r=shaft_r, h=thickness, $fn=32);
        }
    }
    // difference() {
    //     cylinder(r=wt + EwHubInnerRadius, h=wt, $fn=32);
    //     cylinder(r=EwHubInnerRadius, h=wt, $fn=32);
    // }
}

pendulum_mount_arm_length = 60;
pendulum_mount_arm_width = 8;
pendulum_mount_angle = -30;
// Offset the arm so the m8 threaded rod can hang directly below the pivot point.
pendulum_mount_arm_offset = 8;

// This part glues onto the back of the escapement_fork and hangs down
// a little way to provide a mounting point for the pendulum arm.
module pendulum_mount() {
    difference() {
        union() {
            cylinder(r=ForkHubOuterRadius, h=thickness, $fn=32);
            translate([0,-pendulum_mount_arm_width/2+pendulum_mount_arm_offset,0]) cube([pendulum_mount_arm_length+ForkHubOuterRadius, pendulum_mount_arm_width, thickness]);
        }
        cylinder(r=ForkHubInnerRadius, h=thickness, $fn=32);
    }
}

module tjring(ir, or, h) {
    difference() {
        cylinder(r=or, h=h, $fn=32);
        cylinder(r=ir, h=h, $fn=32);
    }
}

pend_shaft_r = (7.83/2)-0.1; // Undersize the hole so the pendulum rod can self-tap
pendulum_hanger_total_x = (pend_shaft_r+wt)*2;
pendulum_arm_x = 5.9; // Measured off an actual arm, includes laser kerf etc.
pendulum_arm_y = pendulum_mount_arm_width-laser_kerf*2; // Measured off an actual arm, includes laser kerf etc.

// This is a little part that attaches to the pendulum arm and makes it
// easier to mount an m8 threaded rod as a pendulum.
module m8_pendulum_hanger(z_scale=1, xy_scale=0) {
    difference() {
        cube([pendulum_hanger_total_x, 3*wt+pend_shaft_r+pendulum_mount_arm_width-laser_kerf*2, thickness]);
        translate([(pendulum_hanger_total_x-pendulum_arm_x)/2,wt,0]) cube([pendulum_arm_x,pendulum_arm_y, 100]);
        translate([pendulum_hanger_total_x/2, wt+pendulum_mount_arm_width-laser_kerf*2+pend_shaft_r, 0]) union() {
            cylinder(r=pend_shaft_r, h=100, $fn=16);
        }
    }
}

// This is the length of one bead and one bit of string.
// 0-0-0-0-0-0-0-...
// | | <-- This distance
bead_chain_straight_pitch = 60.6/10;
bead_r = 4.36/2;
bead_cord_r = 1.61/2;

module bead_chain_segment() {
    sphere(r=bead_r, $fn=16);
    rotate([90,0,0]) cylinder(r=bead_cord_r, h=bead_chain_straight_pitch-bead_r, $fn=16);
}

module bead_chain_ring() {
    bead_n = 30;
    bead_chain_r = bead_chain_straight_pitch/tan(360/bead_n);
    for (i = [0:360/bead_n:360]) {
        rotate([0,0,i]) translate([bead_chain_r,0,0]) rotate([0,0,(-360/bead_n)/2]) bead_chain_segment();
    }
}
bead_n = 16;
bead_chain_r = bead_chain_straight_pitch/tan(360/bead_n);

module bead_chain_gear_solid(simple=0) {
    if (simple) {
        translate([0,0,-thickness*3/2]) cylinder(r=bead_chain_r-bead_cord_r, h=thickness*3);
    } else {
        difference() {
            translate([0,0,-thickness*3/2]) cylinder(r=bead_chain_r-bead_cord_r, h=thickness*3);
            union() {
                for (i = [0:360/bead_n:360]) {
                    rotate([0,0,i]) translate([bead_chain_r,0,0]) rotate([0,0,(-360/bead_n)/2]) bead_chain_segment();
                }
            }
            translate([0,0,-50]) cylinder(r=624_pilot_hole_r, h=100);
            // Alignment key
            translate([624_od/2+(bead_chain_r-624_od/2)/3,-(thickness-laser_kerf)/2,-(thickness*3)/2]) cube([(bead_chain_r-624_od/2)/3, thickness-laser_kerf, thickness*3]);
        }
    }
}

module bead_chain_gear(z_scale=1, xy_scale=0) {
    translate([0,0,z_scale*(-thickness/2+thickness)]) projection(cut=true) bead_chain_gear_solid();
    translate([xy_scale*bead_chain_r*2,0,z_scale*(-thickness/2)]) projection(cut=true) translate([0,0,thickness/2]) bead_chain_gear_solid();
    translate([0,xy_scale*bead_chain_r*2,z_scale*(thickness/2+thickness)]) projection(cut=true) translate([0,0,-thickness/2]) bead_chain_gear_solid();
}

module bead_chain_gear_key(z_scale=1, xy_scale=0) {
    rotate([-90,0,0]) cube([(bead_chain_r-624_od/2)/3, thickness, thickness*3]);
}

// Use calc_ratios.go to generate a nice gear chain.
// sec_to_min = [9, 60, 9, 81];
// sec_to_min = [10, 75, 10, 80]; // Viable.
// sec_to_min = [10, 75, 11, 88]; // Viable.
// sec_to_min = [10,75,10,80];
// sec_to_min = [9,66,11,90];
// sec_to_min = [10,75,11,88];

sec_to_min = [12,90,12,96]; // #1
// sec_to_min = [11,80,12,99];
// sec_to_min = [11,88,12,90];
// sec_to_min = [10,78,13,100];
// sec_to_min = [10,72,12,100];
// sec_to_min = [10,75,12,96];


// The 2mm is to give some clearance between the tips of the escapement wheel and the bearings
// winch_gear_axis_spacing = EwTipRadius+624_od/2+2;
winch_gear_axis_spacing = ForkWheelDistance;
// winch_gear_ratio = 7;
winch_gear_small_tooth_count = sec_to_min[0];
winch_gear_big_tooth_count = sec_to_min[1];
winch_gear_angle = 120;


// These are the gears between the escapement wheel and the bead_chain_gear
module winch_gears(z_scale=1, xy_scale=0) {
    gear_pair(winch_gear_axis_spacing, winch_gear_small_tooth_count, winch_gear_big_tooth_count, thickness*2, 624_od-0.1, 624_pilot_hole_r*2);
}

minute_gear_axis_spacing = ForkWheelDistance;
// minute_gear_ratio = 10;
minute_gear_small_tooth_count = sec_to_min[2];
minute_gear_big_tooth_count = sec_to_min[3];
minute_gear_angle = 60;

// These are the gears between the winch gear and the minute wheel
module minute_gears(z_scale=1, xy_scale=0) {
    gear_pair(minute_gear_axis_spacing, minute_gear_big_tooth_count, minute_gear_small_tooth_count, thickness*2, 624_pilot_hole_r*2, 624_od-0.1);
}

z_scale=1;
xy_scale=0;
batch_export=false;

part_revision_number = 9;
// These are load-bearing comments. The make script awks this file for
// lines between these markers to determine what it needs to render to a file.
// PARTSMARKERSTART
export_escapement_fork = false;
export_escapement_wheel = false;
export_frame = false;
export_m8_pendulum_hanger = false;
export_bead_chain_gear = false;
export_bead_chain_gear_key = false;
export_winch_gears = false;
export_minute_gears = false;
// PARTSMARKEREND

if (batch_export) {
    if (export_escapement_fork) projection() union() {
                escapement_fork();
                translate([ForkWheelDistance,0,0]) rotate([0,0,pendulum_mount_angle]) pendulum_mount();
            }
    if (export_escapement_wheel) projection() escapement_wheel();
    if (export_frame) projection() frame();
    if (export_m8_pendulum_hanger) projection() m8_pendulum_hanger(z_scale, xy_scale);
    if (export_bead_chain_gear) bead_chain_gear(z_scale, xy_scale);
    if (export_bead_chain_gear_key) projection() bead_chain_gear_key(z_scale, xy_scale);
    if (export_winch_gears) projection() winch_gears(z_scale, xy_scale);
    if (export_minute_gears) projection() minute_gears(z_scale, xy_scale);

} else {
                // projection()alignment_tool(z_scale, xy_scale);
    // projection() m8_pendulum_hanger();

    // bead_chain_gear(0, 1);
    // translate([-2,-4,0]) projection() bead_chain_gear_key(0, 1);


// translate([0,0,thickness])    bead_chain_ring();
    // bead_chain_gear(0,1);
    // bead_chain_gear(1,0);
    // bead_chain_gear_solid();
    // bead_chain_gear_key();
    // bead_chain_gear(0, 1);
    // frame();
    // winch_gears();

    // projection() minute_gears(z_scale, xy_scale);
    // #translate([0,0,-thickness]) pendulum_mount();
    // pendulum_mount();
    // translate([30,wt+pendulum_arm_y+pendulum_mount_arm_offset/2,-pendulum_hanger_total_x/2]) rotate([90,0,0]) rotate([90,0,90]) m8_pendulum_hanger();
    render()
    {
        rotate([0,0,180]){
            scale([1,1,2]) union() {
                escapement_fork();
                translate([ForkWheelDistance,0,0]) rotate([0,0,pendulum_mount_angle]) pendulum_mount();
            }
            scale([1,1,2]) escapement_wheel();
            translate([0,0,-z_scale*thickness]) frame();
            translate([0,0,z_scale*thickness*7]) frame();
        }
        translate([0,0,z_scale*thickness*2.5]) rotate([0,0,winch_gear_angle]) winch_gears(z_scale, xy_scale);
        translate([-ForkWheelDistance,0,z_scale*thickness*5]) rotate([0,0,minute_gear_angle]) minute_gears(z_scale, xy_scale);
        rotate([0,0,winch_gear_angle]) translate([winch_gear_axis_spacing,0,z_scale*thickness]) bead_chain_gear_solid(1);
    }
}