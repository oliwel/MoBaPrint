 

module sector(radius, angles, fn = 96) {
    step = -360 / fn;

    points = concat([[0, 0]],
        [for(a = [angles[0] : step : angles[1] - 360]) 
            [radius * cos(a), radius * sin(a)]
        ],
        [[radius * cos(angles[1]), radius * sin(angles[1])]]
    );

    difference() {
        circle(radius, $fn = fn);
        polygon(points);
    }
}

module arc(radius, angle, width = 40) {
    angles = [ 90, 90- angle];
    linear_extrude(1)
    translate([0,-radius,0]) 
    difference() {
        sector(radius + width/2, angles);
        sector(radius - width/2, angles);
    }
} 

module ptranslate( radius, angle ) {
    translate([(sin(angle))*radius,(cos(angle)-1)*radius,0]) 
        rotate([0,0,-angle])
            children();
}
 
translate([-320,0,0]) cube([350,20,85]);
translate([30,0,0]) rotate(-15) {
    color([1,0,0])cube([250,20,85]);
    translate([250,0,0]) rotate(-15) {
        color([1,1,0])cube([250,20,85]);
        color([0,1,0]) translate([70,-5,0]) cube([160,10,60]);
        translate([250,0,0]) rotate(-15) {
            color([0,0,1]) cube([600,20,85]);
            color([0,1,1]) translate([0,60,0]) cube([600,20,85]);
            color([0,1,0]) {
                translate([20,-5,0]) cube([160,10,60]);
                translate([220,-5,0]) cube([160,10,60]);
                translate([420,-5,0]) cube([160,10,60]);
            }
        }
    }
}

translate([0,40,90]) {
    color ([0,1,0]) translate([-250,-20,0]) cube([1000,40,1]);
    
    color ([1,0,0]) arc(902,15);
    ptranslate(902, 15) {
        arc(618,30);
        ptranslate(618,30) {
            translate([0,-20,0]) color ([0,1,0]) cube([600,40,1]);
            translate([600,0,0]) mirror([0,1,0]) arc(618,45);
        }
    }
         
}