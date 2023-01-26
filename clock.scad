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
shaft_r = 1.5;
thickness = 5;

// This is the part that has a bunch of holes in it for hold the parts
// in place.
module frame() {
    holes = [
                [0,0,0], // Escapement wheel
                [ForkWheelDistance,0,0], // Escapement fork
            ];
    // concat(holes, [0 ,0]);
    difference () {
        for (i = [0:len(holes)-1]) {
            hull() {
                translate(holes[i]) cylinder(r=wt + shaft_r, h=thickness, $fn=32);
                if (i < len(holes)-1) {
                    translate(holes[i+1]) cylinder(r=wt + shaft_r, h=thickness, $fn=32);
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




// gear_pair(60, 15, 30, 15, 12.5);
// gear_pair(60, 9, 60, 15, 3);
projection() {
    render()
    {
        // escapement_fork();
        // escapement_wheel();
    }
    // echo(ForkWheelDistance);
    translate([0,0,-thickness]) frame();
    // #cylinder(r=1.5,h=10, $fn=32);
}