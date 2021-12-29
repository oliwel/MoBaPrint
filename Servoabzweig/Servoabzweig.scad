// oliwel, 2021-12-29 - CC BY-NC-SA.

$fn=150;

// Zeigt den Hebelweg des Servo in der Grafik an
showServo=0;

// Position der Halterungen für das abzweigende Magnetband
// Standard mit 30 Grad links / rechts
servocase([-15,15]);

// 5-fach Abzweig mit 22.5 Grad Raster
//servocase([-45,-22.5,0,22.5,45]);

module servocase(angle) {
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
                // Halterung vorne, Bohrung bei 12mm
                intersection() {
                    color([0.5,0.5,0])
                    translate([10.25, -5, 0])
                    cube([4,10,15]);

                    color([0.5,0.5,0])
                    rotate(-20, [0,0,1])
                    rotate_extrude(angle = 40, convexity = 10)
                    translate([10.25, 0, 0])
                    square([3.75,15]);
                }
                // Bohrung
                color([0,0,1]) translate([12,0,9]) cylinder(9, 0.9, 0.9);
            }

            difference() {
                // Halterung hinten, Bohrung bei 15.5mm
                intersection() {
                    color([0.5,0.5,0])
                    translate([-17.25, -5, 0])
                    cube([4,10,15]);

                    color([0.5,1,0])
                    rotate(160, [0,0,1])
                    rotate_extrude(angle = 40, convexity = 10)
                    translate([13.25, 0, 0])
                    square([4,15]);
                }
                // Bohrung
                color([0,0,1]) translate([-15.5,0,9]) cylinder(9, 0.9, 0.9);
            }
        }
        color([0,0,1]) {
            translate([-19,-1.75,-0.6]) cube([8,3.5,1.6]);
            for (rot = angle)
                rotate(rot)
                    translate([14,-1.75,-0.6]) color([0,0,1]) cube([5,3.5,1.6]);
        }
    }

    if (showServo) {
        translate([-6, 0, 0]) color([0,1,1]) {
            // Blende für Magnetband
            rotate( angle[0]-10 , [0,0,1])
            rotate_extrude(angle = rim, convexity = 10)
            square([16,3]);
        }
    }
}
