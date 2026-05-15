
h=50;			//	cylinder height
n=30;			//	number of honeycombs on a circle
dw=4.9;		//	distance between honeycomb faces
h1=3;			// Höhe pro Zelle
w=0.5;		//	Abstand der Zellen
an=0;  // Winkel zur Oberfläche
$fn=32;

// Winkel pro Zelle
ds=(dw-w)/sin(360/6);
// Kreisdurchmesser
dc=((n*dw)/(2*PI))*2;
dh=dw*sin(360/6);


module st() {
	difference() {
		translate([dc/2, 0,0]) cube([h1*2, ds/2, ds/2]);// rotate([0,90,0]) cylinder(h1*2, ds/2, ds/2, $fn=6, true);
		/*for (r1=[0:2])
			translate([dc/2+h1, 0,0]) rotate([r1*120,0,0]) rotate([0,-an,0]) translate([0.01,-dw/2,0]) cube([h1*2,dw,dw]);*/
		}/// df

} // mod st;

module sotc() {
	difference() {
		cylinder(h+0.1, dc/2, dc/2, $fn=128);
		for (hn=[dh:dh*2:h/2+dh])
			translate([0,0,hn])
			for (r=[0:n-1]) {
				translate([dc/2, 0,0])
					translate([0,0,dh/2]) rotate([0,0,360/n*r]) cube([h1*2, ds/2, ds/2]);
						translate([0,0,-dh/2]) rotate([0,0,360/n/2]) rotate([0,0,360/n*r]) st();
			} // for
	} // df
} // mod sotc


sotc();