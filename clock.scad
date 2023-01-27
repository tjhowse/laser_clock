include <escapement.scad>

// https://www.thingiverse.com/thing:3575
use <parametric_involute_gear_v5.0.scad>

module gear_pair(shaft_offset, tooth_count_1, tooth_count_2, gear_thickness, bore_diameter) {

    circular_pitch = shaft_offset*2 / (tooth_count_1 + tooth_count_2) * 180;

    gear (circular_pitch=circular_pitch,
        number_of_teeth=tooth_count_1,
        gear_thickness = gear_thickness,
        rim_thickness = gear_thickness,
        bore_diameter=bore_diameter);

    translate([shaft_offset,0,0]) rotate([0,0,(360/tooth_count_2)/2])
    gear (circular_pitch=circular_pitch,
        number_of_teeth=tooth_count_2,
        gear_thickness = gear_thickness,
        rim_thickness = gear_thickness,
        bore_diameter=bore_diameter);
}

wt = 4;
shaft_r = 2;
thickness = 3;

hanger_x = ForkWheelDistance/2;
hanger_y = -ForkWheelDistance;

// This is the part that has a bunch of holes in it for hold the parts
// in place.
module frame() {
    holes = [
                [0,0,0], // Escapement wheel
                [ForkWheelDistance,0,0], // Escapement fork
                [hanger_x,hanger_y,0], // Hanger
    ];
    // concat(holes, [0 ,0]);
    difference () {
        for (i = [0:len(holes)-1]) {
            for (j = [0:len(holes)-1]) {
                if (i != j) {
                    hull() {
                        translate(holes[j]) cylinder(r=wt + shaft_r, h=thickness, $fn=32);
                        translate(holes[i]) cylinder(r=wt + shaft_r, h=thickness, $fn=32);
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
    translate([xy_scale*ForkHubOuterRadius,xy_scale*ForkHubOuterRadius*sqrt(3),z_scale*thickness*2]) tjring(ForkHubInnerRadius, ForkHubOuterRadius, thickness);
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

z_scale=1;
xy_scale=0;
batch_export=false;

// These are load-bearing comments. The make script awks this file for
// lines between these markers to determine what it needs to render to a file.
part_revision_number = 2;
// PARTSMARKERSTART
print_escapement_fork = false;
print_escapement_wheel = false;
print_pendulum_mount = false;
print_pendulum_washers = false;
print_hanger_washers = false;
print_frame = false;
print_string_hub = false;
// PARTSMARKEREND

if (batch_export) {
    if (print_escapement_fork) projection() escapement_fork();
    if (print_escapement_wheel) projection() escapement_wheel();
    if (print_pendulum_mount) projection() pendulum_mount();
    if (print_pendulum_washers) projection() pendulum_washers(z_scale, xy_scale);
    if (print_hanger_washers) projection() hanger_washers(z_scale, xy_scale);
    if (print_frame) projection() frame();
    if (print_string_hub) projection() string_hub(z_scale, xy_scale);

} else {

    render()
    {
        rotate([0,0,180]){
            scale([1,1,2]) escapement_fork();
            scale([1,1,2]) escapement_wheel();
            translate([ForkWheelDistance,0,z_scale*thickness*2]) rotate([0,0,90]) union() {
                pendulum_mount();
            translate([0,0,z_scale*thickness]) pendulum_washers(z_scale, xy_scale);
            }
            translate([hanger_x, hanger_y,0]) hanger_washers(z_scale, xy_scale);
            translate([0,0,-z_scale*thickness]) frame();
            translate([0,0,z_scale*thickness*6]) frame();
        }
        translate([0,0,z_scale*thickness*2]) string_hub(z_scale, xy_scale);
    }
}