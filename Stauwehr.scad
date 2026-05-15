translate([0,0,0.4]) difference() {
cube([74,20,0.8],true);
cube([40,15,1],true);    
translate([30,0,0]) cube([15,15,1],true);
translate([-30,0,0]) cube([15,15,1],true);
}
translate([0,-9.6,1.4]) cube([74,0.8,2.8],true);