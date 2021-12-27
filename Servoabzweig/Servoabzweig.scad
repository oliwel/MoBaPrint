# oliwel, 2021-12-27 - CC BY-NC-SA.

$fn=150;

// Position der Halterungen für das abzweigende Magnetband
angle = [-45,-22.5,0,22.5,45];

rim = angle[len(angle)-1] - angle[0] + 20;

difference() {
    union() {
        // Grundplatte (38mm)
        color([1,0,0]) {
            translate ([0,0,-0.6]) cylinder(0.6,19,19);
            // Zentrierring (34,5mm)
            rotate_extrude(convexity = 10)
            translate([16.25, 0, 0])
            square([1,3]);


            // Blende für Magnetband
            rotate( angle[0]-10 , [0,0,1])
            rotate_extrude(angle = rim, convexity = 10)
            translate([13, 0, 0])
            square([1,2]);
        }

        difference() {
            // Halterung vorne, Bohrung bei 12.5mm
            color([0.5,0.5,0])
            rotate(-9, [0,0,1])
            rotate_extrude(angle = 18, convexity = 10)
            translate([10.25, 0, 0])
            square([3.75,15]);

            // Bohrung
            color([0,0,1]) translate([12.5,0,8]) cylinder(8, 0.8, 0.8);
        }

        difference() {
            // Halterung hinten,  Bohrung bei  15mm
            union() {
                color([0.5,0.5,0])
                rotate(172.5, [0,0,1])
                rotate_extrude(angle = 15, convexity = 10)
                translate([12.25, 0, 0])
                square([5,15]);

                color([0.5,1,0])
                rotate(167.5, [0,0,1])
                rotate_extrude(angle = 25, convexity = 10)
                translate([12.25, 0, 0])
                square([5,3]);
            }
            // Bohrung
            color([0,0,1]) translate([-15,0,8]) cylinder(8, 0.8, 0.8);
        }
    }

    color([0,0,1]) {
        translate([-19,-1.75,-0.6]) cube([8,3.5,1.6]);
        for (rot = angle)
            rotate(rot)
                translate([14,-1.75,-0.6]) color([0,0,1]) cube([5,3.5,1.6]);
    }
}
