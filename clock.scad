include <escapement.scad>

// https://www.thingiverse.com/thing:3575
use <parametric_involute_gear_v5.0.scad>

module gear_pair(shaft_offset, tooth_count_1, tooth_count_2, gear_thickness, bore_diameter) {

    circular_pitch = shaft_offset*2 / (tooth_count_1 + tooth_count_2) * 180;

    gear (circular_pitch=circular_pitch,
        number_of_teeth=tooth_count_1,
        gear_thickness = gear_thickness,
        rim_thickness = gear_thickness,
        bore_diameter=bore_diameter,
        hub_thickness=gear_thickness);

    translate([shaft_offset,0,0]) rotate([0,0,(360/tooth_count_2)])
    gear (circular_pitch=circular_pitch,
        number_of_teeth=tooth_count_2,
        gear_thickness = gear_thickness,
        rim_thickness = gear_thickness,
        bore_diameter=bore_diameter,
        hub_thickness=gear_thickness);
}

wt = 4;
shaft_r = 2;
thickness = 2.87;

hanger_x = ForkWheelDistance/2;
hanger_y = -ForkWheelDistance;

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
pendulum_mount_arm_width = 6;
624_od = 13;
624_id = 4;

// This part glues onto the back of the escapement_fork and hangs down
// a little way to provide a mounting point for the pendulum arm.
module pendulum_mount() {
    difference() {
        union() {
            cylinder(r=ForkHubOuterRadius, h=thickness, $fn=32);
            translate([0,-pendulum_mount_arm_width/2,0]) cube([pendulum_mount_arm_length+ForkHubOuterRadius, pendulum_mount_arm_width, thickness]);
        }
        cylinder(r=ForkHubInnerRadius, h=thickness, $fn=32);
    }
}

// These make sure the pendulum/escapement fork stack add up to the same
// thickness as the escapement wheel/string hub stack.
module pendulum_washers(z_scale=1, xy_scale=0) {
    translate([0,0,0]) tjring(ForkHubInnerRadius, ForkHubOuterRadius, thickness);
    translate([xy_scale*ForkHubOuterRadius*2,0,z_scale*thickness]) tjring(ForkHubInnerRadius, ForkHubOuterRadius, thickness);
    translate([0,xy_scale*ForkHubOuterRadius*2,z_scale*thickness]) tjring(ForkHubInnerRadius, ForkHubOuterRadius, thickness);
    translate([xy_scale*ForkHubOuterRadius,xy_scale*ForkHubOuterRadius*sqrt(3),z_scale*thickness*2]) tjring(ForkHubInnerRadius, ForkHubOuterRadius, thickness);
    translate([xy_scale*ForkHubOuterRadius,xy_scale*ForkHubOuterRadius*sqrt(3),z_scale*thickness*3]) tjring(ForkHubInnerRadius, ForkHubOuterRadius, thickness);
}

module hanger_washers(z_scale=1, xy_scale=0) {
    for (i = [0:6]) {
        translate([i*(624_id/2+wt)*2*xy_scale,0,i*z_scale*thickness]) tjring(624_id/2,624_id/2+wt,thickness);
    }
}

string_hub_r = 30;
string_hub_r_lip = 2;

module tjring(ir, or, h) {
    difference() {
        cylinder(r=or, h=h, $fn=32);
        cylinder(r=ir, h=h, $fn=32);
    }
}

// This is glued to the back of the escapement wheel and is used to wind up the
// string and bob for providing torque to the escapement wheel. call with (0,1) to
// see it exploded for cutting, (1,0) to see it stacked up for modelling.
module string_hub(z_scale=1, xy_scale=0) {
    big = string_hub_r+string_hub_r_lip;
    translate([0,0,0]) tjring(624_od/2, big, thickness);
    translate([xy_scale*big*2,0,z_scale*thickness]) tjring(624_od/2, string_hub_r, thickness);
    translate([0,xy_scale*big*2,z_scale*thickness*2]) tjring(624_od/2, string_hub_r, thickness);
    translate([xy_scale*big*2,xy_scale*big*2,z_scale*thickness*3]) tjring(624_od/2, big, thickness);
}

// This is a little part that attaches to the pendulum arm and makes it
// easier to mount an m8 threaded rod as a pendulum.
module m8_pendulum_hanger(z_scale=1, xy_scale=0) {
    pend_shaft_r = 4;
    m8_nut_r = 12.77/2;
    total_x = pendulum_mount_arm_width+2*wt;
    difference() {
        cube([total_x, 2*wt+m8_nut_r+pend_shaft_r+thickness, thickness]);
        translate([wt+laser_kerf,wt,0]) cube([pendulum_mount_arm_width-laser_kerf*2, thickness, 100]);
        translate([total_x/2, wt+thickness+m8_nut_r, 0]) union() {
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
bead_n = 30;
bead_chain_r = bead_chain_straight_pitch/tan(360/bead_n);

module bead_chain_gear_solid() {
    // tooth_xy = bead_r*2;
    // bead_n = 20;
    // bead_chain_r = bead_chain_straight_pitch/tan(360/bead_n);
    // for (i = [0:360/bead_n:360]) {
    //     rotate([0,0,i+360/bead_n/2]) translate([bead_chain_r-tooth_xy/sqrt(2),0,0]) rotate([0,0,(-360/bead_n)/2]) union() {
    //         rotate([0,0,-45]) cube([tooth_xy,tooth_xy,thickness],center=true);
    //     }
    // }
    difference() {
        translate([0,0,-thickness*3/2]) cylinder(r=bead_chain_r-bead_cord_r, h=thickness*3);
        union() {
            for (i = [0:360/bead_n:360]) {
                rotate([0,0,i]) translate([bead_chain_r,0,0]) rotate([0,0,(-360/bead_n)/2]) bead_chain_segment();
            }
        }
        translate([0,0,-50]) cylinder(r=624_od/2, h=100);
    }
}

module bead_chain_gear(z_scale=1, xy_scale=0) {
    translate([0,0,z_scale*(-thickness/2+thickness)]) projection(cut=true) bead_chain_gear_solid();
    translate([xy_scale*bead_chain_r*2,0,z_scale*(-thickness/2)]) projection(cut=true) translate([0,0,thickness/2]) bead_chain_gear_solid();
    translate([0,xy_scale*bead_chain_r*2,z_scale*(thickness/2+thickness)]) projection(cut=true) translate([0,0,-thickness/2]) bead_chain_gear_solid();
}

// winch_gear_axis_spacing = ForkWheelDistance;
 // The 2mm is to give some clearance between the tips of the escapement wheel and the bearings
winch_gear_axis_spacing = EwTipRadius+624_od/2+2;
echo(winch_gear_axis_spacing);
winch_gear_ratio = 3;
winch_gear_small_tooth_count = 9;
winch_gear_angle = 60;

// These are the gears between the escapement wheel and the bead_chain_gear
module winch_gears(z_scale=1, xy_scale=0) {
    gear_pair(winch_gear_axis_spacing, winch_gear_small_tooth_count, winch_gear_small_tooth_count*winch_gear_ratio, thickness*2, 624_od);
}

z_scale=1;
xy_scale=0;
batch_export=false;
laser_kerf = 0.3;

part_revision_number = 3;
// These are load-bearing comments. The make script awks this file for
// lines between these markers to determine what it needs to render to a file.
// PARTSMARKERSTART
export_escapement_fork = false;
export_escapement_wheel = false;
export_pendulum_washers = false;
export_hanger_washers = false;
export_frame = false;
export_string_hub = false;
export_m8_pendulum_hanger = false;
export_bead_chain_gear = false;
// PARTSMARKEREND

if (batch_export) {
    if (export_escapement_fork) projection() union() {
                escapement_fork();
                translate([ForkWheelDistance,0,0]) rotate([0,0,90]) pendulum_mount();
            }
    if (export_escapement_wheel) projection() escapement_wheel();
    if (export_pendulum_washers) projection() pendulum_washers(z_scale, xy_scale);
    if (export_hanger_washers) projection() hanger_washers(z_scale, xy_scale);
    if (export_frame) projection() frame();
    if (export_string_hub) projection() string_hub(z_scale, xy_scale);
    if (export_m8_pendulum_hanger) projection() m8_pendulum_hanger(z_scale, xy_scale);
    if (export_bead_chain_gear) projection() bead_chain_gear(z_scale, xy_scale);

} else {
                // projection()alignment_tool(z_scale, xy_scale);
    // projection() m8_pendulum_hanger();
// translate([0,0,thickness])    bead_chain_ring();
    // bead_chain_gear(0,1);
    // bead_chain_gear(1,0);
    // bead_chain_gear_solid();
    // frame();
    // winch_gears();
    render()
    {
        rotate([0,0,180]){
            scale([1,1,2]) union() {
                escapement_fork();
                translate([ForkWheelDistance,0,0]) rotate([0,0,90]) pendulum_mount();
            }
            scale([1,1,2]) escapement_wheel();
            translate([ForkWheelDistance,0,z_scale*thickness]) rotate([0,0,90]) union() {
                translate([0,0,z_scale*thickness]) pendulum_washers(z_scale, xy_scale);
            }
            translate([hanger_x, hanger_y,0]) hanger_washers(z_scale, xy_scale);
            translate([0,0,-z_scale*thickness]) frame();
            translate([0,0,z_scale*thickness*7]) frame();
        }
        // translate([0,0,z_scale*thickness*2]) string_hub(z_scale, xy_scale);
        // translate([0,0,z_scale*thickness*3.5]) bead_chain_gear_solid();
        translate([0,0,z_scale*thickness*2]) rotate([0,0,winch_gear_angle]) winch_gears(z_scale, xy_scale);
        rotate([0,0,winch_gear_angle]) translate([winch_gear_axis_spacing,0,z_scale*thickness*5.5]) bead_chain_gear_solid();
    }
}