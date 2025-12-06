// Lenovo ThinkCentre Tiny Series Under-desk Mount
// Designed for 180mm x 180mm print beds (Must print diagonally!)
//
// Print it twice. Inset M4 nut into the retaining holdes.
// Mount the brackets, use a thumbscrew or grubscrew to secure.
//
// Print on its side, else you're going to find you're Tiny on the floor.


/* [Printer Settings] */
// To fit 180mm bed, we rotate the part 45 degrees
rotate_for_print = true; 

/* [PC Dimensions] */
// Width of the PC (usually ~179mm-182mm for Tiny series)
pc_width = 183.0; // Added 1mm tolerance
// Height/Thickness of the PC (usually ~37mm)
pc_height = 38.0; // Added 1mm tolerance

/* [Bracket Dimensions] */
// Depth of a single bracket (Z-axis height during print)
bracket_depth = 30; 
// Thickness of the walls
wall_thick = 5;
// Width of the mounting tabs
tab_width = 15;

/* [Security] */
// Diameter of the locking screw hole (M5 = 5.2, M4 = 4.2)
screw_hole_dia = 4.8; 
// Size of the nut trap (0 to disable nut trap)
nut_trap_width = 8.2; // Standard M5 nut is ~8mm flat-to-flat
nut_trap_depth = 3.5;

/* [Hidden] */
$fn = 60;

module main_body() {
    total_width = pc_width + (wall_thick * 2);
    total_height = pc_height + (wall_thick); // Bottom wall only, top is open
    
    difference() {
        // Outer Shell
        union() {
            // Main U-Shape
            translate([-total_width/2, 0, 0])
            cube([total_width, total_height, bracket_depth]);
            
            // Mounting Tabs (Ears)
            for (i = [-1, 1]) {
                translate([(i * (total_width/2 + tab_width/2)), total_height - wall_thick/2, bracket_depth/2])
                hull() {
                    cube([tab_width, wall_thick, bracket_depth], center=true);
                    // Fillet to main body
                    // Shifted down (-wall_thick/2) so the top of the cylinder is flush with the top of the tab
                    translate([-i * tab_width/2, -wall_thick/2, 0])
                    cylinder(r=wall_thick, h=bracket_depth, center=true);
                }
            }
        }

        // Inner Cutout (The PC Slot)
        translate([-pc_width/2, wall_thick, -1])
        cube([pc_width, pc_height + 10, bracket_depth + 2]);
        
        // Chamfer/Round the entry edges for easier insertion
        // (Simple subtraction for clean slide-in)
        translate([-pc_width/2, wall_thick-10, -5])
        rotate([-45, 0, 0])
        cube([pc_width, 5, bracket_depth + 10]);

        // Mounting Screw Holes (Countersunk)
        for (i = [-1, 1]) {
            translate([(i * (total_width/2 + tab_width/2)), total_height + 5, bracket_depth/2])
            rotate([90, 0, 0]) {
                cylinder(d=5, h=20); // Screw shaft
                translate([0, 0, 5 + wall_thick])
                cylinder(d=10, h=10); // Screw head clearance
            }
        }
        
        // Security/Locking Screw Hole (Bottom Center)
        translate([0, -1, bracket_depth/2])
        rotate([-90, 0, 0])
        cylinder(d=screw_hole_dia, h=wall_thick + 10);
        
        // Hex Nut Trap (Optional)
        if (nut_trap_width > 0) {
            translate([0, wall_thick - nut_trap_depth + 0.1, bracket_depth/2])
            rotate([-90, 90, 0])
            cylinder(r=nut_trap_width/2 / cos(30), h=nut_trap_depth + 1, $fn=6);
        }
    }
}

// Positioning logic
if (rotate_for_print) {
    // Rotates 45 degrees to fit diagonal of 180mm bed
    // (180^2 + 180^2)^0.5 = ~254mm diagonal space
    // Part width is approx 183 + 10 + 30 = ~223mm
    rotate([0, 0, 45])
    main_body();
} else {
    main_body();
}