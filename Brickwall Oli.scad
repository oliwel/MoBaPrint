wid=6;
hei=3;
dep=1;
$fn=1;

module stone() {
    lw=wid/3;
    lh=hei/2;
    random_vect=rands(0,1,12);
    coords = [
        [0,-random_vect[0]],
        [lw,-random_vect[1]],
        [2*lw,-random_vect[2]],
        [wid+random_vect[3],-random_vect[4]],
        [wid+random_vect[5],lh],
        [wid+random_vect[6],hei+random_vect[7]],
        [2*lw,hei+random_vect[8]],
        [lw,hei+random_vect[9]],
        [0,hei+random_vect[10]],
        [-random_vect[11],lh]
    ];
    translate([1.5,1.5,0]) minkowski(){
        cylinder(1,d=1);
        linear_extrude(1) polygon(coords);
    }
}
stone();
for (xp = [0:5]) {
    for (yp = [0:5]) {
        translate([xp*(wid+3),yp*(hei+3),0]) stone();
    }
}