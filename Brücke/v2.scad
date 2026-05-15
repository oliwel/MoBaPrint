$fn=128;
//    import("24_Inch_Radius_-_W.stl");

// track radius
rd=618;
// track width
tw=70;
// outer rim
or=rd+tw/2;
// inner rim
ir=rd-tw/2;
// angle per segment
ag=5;

//polygon([[0,ir],[0,or],[sin(ag)*or,cos(ag)*(or)], [sin(ag)*ir,cos(ag)*(ir)]]);



cube([3,tw,3],true);
rotate([0,0,-ag]) cube([3,tw,3],true);

//translate([sin(ag)*ir,0,0]) rotate([0,0,-ag]) cube([3,tw,3]);
//translate([0,tw,0]) rotate([0,0,-90-ag]) cube([3,tw,3]);



 
