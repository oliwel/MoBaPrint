difference(){
cylinder(22,17.5,17.5);
translate([0,0,0.5]) cylinder(24,14.0,14.0);
translate([0,0,15]) 
    union() {
    cylinder(20,17.0,17.0);
    cube([20,20,20]);
    }
}