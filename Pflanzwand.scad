wall = 0.6;


difference() {
    union() {
color([1,0,0]) translate([0,4,0]) rotate([90,0,0]) 
    linear_extrude(4) polygon(points=[[0,0],[25,0],[2,75],[0,75]]);		 

for (ii = [0:4]) translate([0,0,ii*15]) {
    xx = 18-ii*4.5;
    color([0,1,0]) translate([xx, 0, 0]) cube([10,50,1.5]);    
    translate([xx+10 ,0, 0]) cube([2,50,4]);    
    translate([xx, 0, 0]) cube([1,50,15]);        
}
translate([0,0,75]) cube([3,50,1.5]);
translate([3,0,75]) cube([2,50,4]);
}
 translate([0,0,46.5]) cube([14.5,50,40]);
cube([5,50,80]);
//color ([0,0,1]) translate([0,50 -  sin(15)*40,0])  rotate([0,0,15]) cube([50,20,80]);
}
