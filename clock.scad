import("escapement.scad");


use <parametric_involute_gear_v5.0.scad>



// shaft_offset = pump_r+wt+gearbox_r-gearbox_out_centre_offset;
shaft_offset = 50;
tooth_count_1 = 20;
tooth_count_2 = 20;
circular_pitch = shaft_offset / tooth_count * 180;
gear_thickness = 15;


gear (circular_pitch=circular_pitch,
    number_of_teeth=tooth_count_1,
    gear_thickness = gear_thickness,
    rim_thickness = gear_thickness,
    bore_diameter=12.5);

// translate([shaft_offset,0,0]) rotate([0,0,(360/tooth_count*tooth_ratio)/2])
gear (circular_pitch=circular_pitch,
    number_of_teeth=tooth_count_2,
    gear_thickness = gear_thickness,
    rim_thickness = gear_thickness,
    bore_diameter=12.5);