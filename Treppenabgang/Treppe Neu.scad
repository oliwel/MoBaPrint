gap=0.3;
wid=22; 
lwid=40; 

intersection() {   
    color([0,0,1]) linear_extrude(32) polygon([[0,0],[wid,0],[lwid,40],[0,40]]);
    // Stufen oberes Segment
    union(){
        translate([0,8,0]) rotate([0,0,-16]) for (ii=[1:8]) {
            rotate([0,0,2*ii]) translate([-5,(ii-1)*4,0]) cube([5+lwid,6,ii*2+16]);
        }
        // Podest
        color([0,1,1])cube([50,50,16]);
    }
}

// Podest
color([0,1,1]) rotate([0,0,-15]) translate([0,-4,0]) cube([22,20,16]);
// Stufen unteres Segment
color([1,1,0]) rotate([0,0,-15]) translate([0,-32,0]) for (ii=[1:8]) {
    translate([0,(ii-1)*4,0]) cube([wid,6,ii*2]);
}

color([1,0,1]) 
linear_extrude(16) polygon([[0,0],[22/cos(0.30)+3,0],[43,40],[0,40]]);