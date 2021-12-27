// Globale Werte
// Stärke der Flächen (Wand, Boden)
wall = 0.6;

/* Das Marko stairs erstellt eine einfache Treppe mit seitlichen Mauern
 * Die Standardparamter sind eine Treppe mit 14 Stufen zu 3/2mm was
 * in etwa einem Stockwerk mit einer Treppe nach DIN entspricht.
 * l = horizontale Gesamtlänge der Treppe
 * w = Breite der Treppen (inkl. Wand)
 * h = Höhenunterschied (exklusive Bodenplatte)
 * n = Anzahl der Stufen
 * bl = Länge der Bodenplatte (0 = ohne)
 * bd = up: Wände nach oben, down = Wände nach unten
 * o = Überlappung der Treppenstufen, Standardwert = 0.2
 */
module stairs(l=42,w=20,h=28,n=14,bl=12,bd="up",o=0.2) {
	il = l/n;
	ih = h/n;

	if (bl != 0) {
		translate([0,0,-wall]) cube([w,bl+il-2*o,wall]);
	}
	translate([0,bl,0]) {
		// draw individual steps
		// move overlay units to inside to avoid edges in hull
		for(i=[0 : n-1]) translate([o,il*i-o,ih*i]) cube([w-2*o,il+o,ih]);
		hull() {
			if (bl != 0) {
				translate([0,il-o-wall,-wall]) cube([w,2*o,2*o]);
			}
			translate([0,il+o,0]) cube([w,2*o,2*o]);
			translate([0,l-2*o,h-ih]) cube([w,2*o,2*o]);
		}
		for (x = [0,w-wall]) {
			color([1,0,0]) hull() {
				translate([x,il,0]) cube(wall);
				translate([x,l-wall,h-ih]) cube(wall);
				translate([x,l-wall,h-wall]) cube(wall);
				if (bd == "up") {
					translate([x,-bl,h-wall]) cube(wall);
					translate([x,-bl,0]) cube(wall);
				} else {
					translate([x,l-wall,0]) cube(wall);
				}
			}
		}
		color([0,0,0.5]) translate([0,l-wall,0]) {
			cube([wall,wall,h]);
			translate([w-wall,0,0]) cube([wall,wall,h]);
			if (bl != 0) {
				translate([0,0,-wall]) cube([w,wall,wall]);
			} else {
				cube([w,wall,wall]);
			}
		}
	}

}

stairs();
//stairs(18,22,13,6,12);
/*translate([0,30,13]) stairs(18,width,13,6,8);
color([0.5,0,0]) {
	for (x = [0,width-wall]) {
		translate([x,0,13]) cube([wall,38,7+wall]);
		translate([x,12,20]) rotate(90,[0,0,1]) rotate(90,[1,0,0]) color([0,0,1]) linear_extrude(wall, false) polygon(points=[[0,0],[8,0],[8,5]]);
		 //cube([wall,8,5]);
		translate([x,20,20]) cube([wall,6,6]);
	}
}*/

/*
color([0,0.5,0]) {
	translate([0,0,20]) cube([width,25,wall]);
 	//translate([0,25,20]) rotate(-60,[1,0,0]) cube([width,wall,5]);
	translate([0,30,25-wall]) cube([width,2,wall]);
	hull() {
		translate([0,32-wall,25-wall]) cube([width,wall,wall]);
		translate([0,25-wall,20]) cube([width,wall,wall]);
	}
}*/
/*
color([0,0,0.5]) translate([0,56-wall,0]) {
	translate([0,0,0]) cube([width,wall,wall]);
	translate([0,0,0]) cube([wall,wall,26]);
	translate([width-wall,0,0]) cube([wall,wall,26]);
}*/