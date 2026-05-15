$fn=50;

difference(){
    union() {
        cylinder(10.3, d=6.6);

        cylinder(0.2, d=6.8);
        cylinder(0.1, d=7.0);

        translate([0,0,3.3]) cylinder(0.3, d=6.8);
        translate([0,0,3.4]) cylinder(0.1, d=7.0);

        translate([0,0,6.7]) cylinder(0.3, d=6.8);
        translate([0,0,6.8]) cylinder(0.1, d=7.0);

        translate([0,0,10.1]) cylinder(0.2, d=6.8);
        translate([0,0,10.2]) cylinder(0.1, d=7.0);
    }
    translate([0,0,10.1]) cylinder(0.4, d=5.8);
    cylinder(10.3, d=5.0);
}

color([0,1,0])
difference(){
    cylinder(3.0, d=6.6);
    cylinder(3.0, d=3.0);
    cylinder(1.5, d=4);
}

translate([0,0.7,10]) rotate([15,0,0]) cylinder(0.4, d=6);