$fn=25;

segment_length = 38;
segment_count = 5;

module pole_foot() {
    translate([-6.9,0.4,0]) rotate([-90,90,-90]) {
    difference() {
        union() {
            translate([-0.6,0,0])  cube([1.2,1,7.5]);
            translate([-0.6,-1.2,0])  cube([1.2,1.2,0.6]);
        }
        translate([-0.2,0.4,0]) cube([0.4,0.6,7.5]);
    }
    }
}

module pole( height = 7.5 ) {
    translate([-height+0.6,0.4,0]) rotate([-90,90,-90]) {
    difference() {
        translate([-0.6,0,0])  cube([1.2,1,height]);
        translate([-0.2,0.4,0]) cube([0.4,0.6,height]);    
    }}
}


module segment( length = 22 ) {
    translate([0,0,0.8]) rotate([90,0,180]) {
        difference() {
        union() {
            translate([-1,0,0]) cylinder(length,0.8,0.8);
            translate([-1.8,0,0]) cube([3.6,0.8,length]);
            translate([1,0,0]) cylinder(length,0.8,0.8);
        }
        translate([-1.8,0.4,0]) cube([1.2,0.4,length]);
        translate([0.6,0.4,0]) cube([1.2,0.4,length]);        
    }
      
    pole_foot();
    translate([-7.5,0,0]) pole_foot();
    }
}

for (i = [0:segment_count-1]) {
    translate([0,i*segment_length,0]) segment(segment_length);
}