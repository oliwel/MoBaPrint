include <arduino.scad>
//translate([0,0,0]) enclosure(UNO, 2, 3, 20, 5, PIN);

wall = 2;
iw = 65;
ih = 40;
il = 100;

difference() {
    translate([-wall, -wall, -wall]) roundedCube([iw+2*wall,100+2*wall,ih+wall]);
    roundedCube([iw,il,ih+wall]);
    for (posy = [(il * 0.25), (il * 0.75) ]) {
        translate([0, posy, 0]) {
            translate([0, 0, 0])
                rotate([0, 0, 90]) clipHole(clipHeight = ih-10+wall, holeDepth = wall + 0.2);
            translate([iw, 0, 0])
                rotate([0, 0, 270]) clipHole(clipHeight = ih-10+wall, holeDepth = wall + 0.2);
        }
    }
    // Zuleitung
    translate([-wall,5,ih-wall-5]) {
        cube([wall,4,2]);
        translate([0,6,-0.25]) cube([wall,5,2.5]);
    }

    // Tastaturkabel
    translate([0.5*iw, 0.5*il , -0.5*wall]) cube([5,15,
    wall], true);
}
translate([((iw-55)/2), (il-72), 0]) {
//    translate([0, 0, 5]) arduino();
    standoffs( height = 7 );
}



//rotate([0, 180, 180])  translate([0, -il, -ih]) 
translate([-100, 0, 0])  union() {
    translate([-wall, -wall, -wall]) roundedCube([iw+2*wall,100+2*wall,wall]);
    roundedCube([iw,il,wall]);
    //Lid clips
    for (posy = [(il * 0.25), (il * 0.75) ]) {
        translate([0, posy, 0]) {
            translate([0, 0, 0])
                rotate([0, 0, 90]) clip(clipHeight = 10);
            translate([iw, 0, 0])
                rotate([0, 0, 270]) clip(clipHeight = 10);
        }
    }
};