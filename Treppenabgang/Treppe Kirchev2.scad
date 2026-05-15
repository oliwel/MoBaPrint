gap=0.3;
wid=25; 
lwid=50; 

deg=atan(50/80);
h=sin(deg)*25;
w=tan(deg)*h;
intersection() {
    color([1,1,1]) linear_extrude(34) polygon([[-50,0],[0,0],[0,39],[25,80],[w,80+h]]);
    union() for (ii=[0:16]) rotate([0,0,-ii*(deg/15)]) translate([0,ii*4.75,0]) translate([-50,-3,0]) cube([55,7,34-ii*2]);    
}
color([1,0,1]) linear_extrude(18) polygon([[-53,0],[-50,0],[-25,40],[-28,40]]);