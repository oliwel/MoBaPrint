

module plate() {
    difference() {
        translate([0,-10,0]) cube([110,20,0.8]);
        for (offset = [24:24:110]) {
            translate([offset,-2,0]) cube([3,4,1]);
        }
    }
    translate([0,-10.8,0]) cube([110,0.8,3]);
    translate([21,-2.8,0]) cube([81,0.8,3]);
}
plate();
