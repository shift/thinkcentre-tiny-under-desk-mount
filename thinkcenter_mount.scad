// Lenovo ThinkCentre Tiny Series Under-desk Mount (Stackable)
// Designed for 180mm x 180mm print beds (Must print diagonally!)
//
// Usage:
// 1. Print 2 brackets per PC.
// 2. For the first PC (Desk Mount): Screw top tabs into desk.
// 3. For the second PC (Stack): Insert nuts into the bottom tabs of the first brackets.
//    Use countersunk screws going UP through the top tabs of the second bracket
//    into the bottom tabs of the first bracket.

/* [Preview Options] */
// Enable to see the stacked assembly with PCs. Disable for printing!
preview_assembly = true;
// How many units to show in the preview stack
preview_stack_count = 3;
// Distance between the front and rear brackets in the preview
bracket_spacing = 120; 

/* [Printer Settings] */
// To fit 180mm bed, we rotate the part 45 degrees (Ignored if preview_assembly is true)
rotate_for_print = true;

/* [PC Dimensions] */
// Width of the PC (usually ~179mm-182mm for Tiny series)
pc_width = 183.0; // Added 1mm tolerance
// Height/Thickness of the PC (usually ~37mm)
pc_height = 38.0; // Added 1mm tolerance
// Depth of the PC (for preview only - M-series Tiny is ~183mm)
pc_real_depth = 183.0;

/* [Bracket Dimensions] */
// Depth of a single bracket (Z-axis height during print)
bracket_depth = 30;
// Thickness of the walls
wall_thick = 5;
// Width of the mounting tabs
tab_width = 15;
// Clearance between the top of the PC and the desk surface
airflow_gap = 10;
// Width of the retaining clips/rails that hold the PC down
retainer_clip_width = 3.0;

/* [Stacking] */
// Add mounting tabs to the bottom to allow hanging another unit
enable_stacking = true;
// Width of the nut for stacking (M5=~8mm, M4=~7mm)
stacking_nut_width = 8.2; 
// Depth of the nut trap for stacking
stacking_nut_depth = 3.5;

/* [Security] */
// Diameter of the locking screw hole (M5 = 5.2, M4 = 4.2)
screw_hole_dia = 4.8;
// Size of the side lock nut trap (0 to disable nut trap)
nut_trap_width = 8.2; // Standard M5 nut is ~8mm flat-to-flat
nut_trap_depth = 3.5;

/* [Hidden] */
$fn = 60;

// Added 'stacking' parameter to allow overriding the global setting per-instance
module main_body(stacking = enable_stacking) {
    total_width = pc_width + (wall_thick * 2);
    // Total height now includes the bottom wall, the PC, and the airflow gap
    total_height = pc_height + wall_thick + airflow_gap;

    difference() {
        // Outer Shell
        union() {
            // Main U-Shape
            translate([-total_width/2, 0, 0])
            cube([total_width, total_height, bracket_depth]);

            // Mounting Tabs (Top Ears - To Desk)
            for (i = [-1, 1]) {
                translate([(i * (total_width/2 + tab_width/2)), total_height - wall_thick/2, bracket_depth/2])
                hull() {
                    cube([tab_width, wall_thick, bracket_depth], center=true);
                    // Fillet to main body
                    translate([-i * tab_width/2, -wall_thick/2, 0])
                    cylinder(r=wall_thick, h=bracket_depth, center=true);
                }
            }
            
            // Stacking Tabs (Bottom Ears - To Next Unit)
            // Uses the local parameter 'stacking' instead of global 'enable_stacking'
            if (stacking) {
                for (i = [-1, 1]) {
                    translate([(i * (total_width/2 + tab_width/2)), wall_thick/2, bracket_depth/2])
                    hull() {
                        cube([tab_width, wall_thick, bracket_depth], center=true);
                        // Fillet to main body (matching top style)
                        translate([-i * tab_width/2, wall_thick/2, 0])
                        cylinder(r=wall_thick, h=bracket_depth, center=true);
                    }
                }
            }
        }

        // Inner Cutout (Stepped Profile)
        union() {
            // 1. The PC Slot (Wide bottom section)
            translate([-pc_width/2, wall_thick, -1])
            cube([pc_width, pc_height, bracket_depth + 2]);

            // 2. The Airflow Gap (Narrower top section to create retaining clips)
            // The slot narrows by retainer_clip_width on both sides
            translate([-(pc_width - 2*retainer_clip_width)/2, wall_thick + pc_height - 0.1, -1])
            cube([pc_width - 2*retainer_clip_width, airflow_gap + 10, bracket_depth + 2]);
        }

        // Chamfers (Bevels) for smooth insertion

        // 1. Bottom Floor Chamfer (Existing)
        translate([-pc_width/2, wall_thick-10, -5])
        rotate([-45, 0, 0])
        cube([pc_width, 5, bracket_depth + 10]);

        // 2. Top Retaining Clip Chamfer (New)
        // Bevels the underside of the retaining rails
        translate([-pc_width/2, wall_thick + pc_height + 10 - 2, -5])
        rotate([-135, 0, 0]) // Angles the cut to slope the ceiling entry
        cube([pc_width, 5, bracket_depth + 10]);

        // Mounting Screw Holes (Top Tabs)
        for (i = [-1, 1]) {
            translate([(i * (total_width/2 + tab_width/2)), total_height + 5, bracket_depth/2])
            rotate([90, 0, 0]) {
                cylinder(d=5, h=20); // Screw shaft
                translate([0, 0, 5 + wall_thick])
                cylinder(d=10, h=10); // Screw head clearance (Countersunk)
            }
        }
        
        // Stacking Holes & Traps (Bottom Tabs)
        if (stacking) {
             for (i = [-1, 1]) {
                translate([(i * (total_width/2 + tab_width/2)), 0, bracket_depth/2]) {
                    
                    // Through hole for screw from below
                    rotate([90, 0, 0])
                    translate([0, 0, -wall_thick - 5]) // Extend well past geometry
                    cylinder(d=5, h=wall_thick + 10); 

                    // Nut Trap (On TOP surface of bottom tab)
                    // Located at Y=wall_thick, facing down (-Y)
                    translate([0, wall_thick + 0.1, 0]) 
                    rotate([90, 0, 0])
                    rotate([0, 0, 30]) // Align hex flat
                    cylinder(r=stacking_nut_width/2 / cos(30), h=stacking_nut_depth + 0.1, $fn=6);
                }
             }
        }

        // Security/Locking Screw Hole (Bottom Center)
        translate([0, -1, bracket_depth/2])
        rotate([-90, 0, 0])
        cylinder(d=screw_hole_dia, h=wall_thick + 10);

        // Hex Nut Trap (Optional Side Lock)
        if (nut_trap_width > 0) {
            translate([0, wall_thick - nut_trap_depth + 0.1, bracket_depth/2])
            rotate([-90, 90, 0])
            cylinder(r=nut_trap_width/2 / cos(30), h=nut_trap_depth + 1, $fn=6);
        }
    }
}

// Visual mockup of the PC for preview purposes
module computer_mockup() {
    // Calculate PC placement relative to the bracket pair
    // Center the PC length (pc_real_depth) over the span of the two brackets (bracket_spacing + bracket_depth)
    z_start = (bracket_spacing + bracket_depth)/2 - pc_real_depth/2;

    // A dark grey box for the PC chassis
    color("#333333") 
    translate([-pc_width/2, wall_thick, z_start]) 
    cube([pc_width, pc_height, pc_real_depth]);
    
    // Front Face (Lenovo Style)
    // Assuming positive Z is "Front"
    color("#111111")
    translate([-pc_width/2, wall_thick, z_start + pc_real_depth - 2])
    cube([pc_width, pc_height, 2]);

    // Red Logo Tag
    color("red")
    translate([pc_width/2 - 25, wall_thick + 5, z_start + pc_real_depth])
    cube([15, 5, 0.5]);
    
    // Power Button
    color("black")
    translate([pc_width/2 - 50, wall_thick + pc_height/2, z_start + pc_real_depth])
    rotate([0,90,0])
    cylinder(r=5, h=1);
}

// Logic to display preview or print version
if (preview_assembly) {
    // Calculate vertical offset for stacking
    // We want the 'top tabs' of the lower unit (Y = total_height - wall/2)
    // to align with 'bottom tabs' of upper unit (Y = wall/2)
    // Shift = wall/2 - (total_height - wall/2) = wall - total_height
    total_height = pc_height + wall_thick + airflow_gap;
    stack_offset = wall_thick - total_height;
    
    for (i = [0 : preview_stack_count-1]) {
        translate([0, i * stack_offset, 0]) {
            // Determine if this layer needs stacking tabs
            // The last layer (bottom-most, where i == count-1) should NOT have stacking tabs
            // Otherwise, respect the global enable_stacking flag
            render_tabs = (i == preview_stack_count - 1) ? false : enable_stacking;

            // Bracket 1 (Rear/Base)
            main_body(stacking=render_tabs);
            
            // Bracket 2 (Front)
            translate([0, 0, bracket_spacing])
            main_body(stacking=render_tabs);
            
            // The PC
            %computer_mockup(); // % makes it transparent/ghosted
        }
    }
} else if (rotate_for_print) {
    // Rotates 45 degrees to fit diagonal of 180mm bed
    rotate([0, 0, 45])
    main_body();
} else {
    main_body();
}