$fn=100;    	// zum testen den Wert auf <50 setzen

sl = 15.8+ 0.2;	// Steckerlänge + Toleranz
sb = 8.8 + 0.2; // Steckerbreite + Toleranz
sh = 8.7;		// Steckerhöhe;
rs = 1.2;		// Rahmenstärke
zb = 5.0;		// Breite Zugentlastung
zd = 1.5;		// Schlitzdicke Zugentlastung
db  = 20-0.5;   // Durchmesser Bohrung abzüglich Toleranz für leichteren Einbau
ra = 2;			// Überstand Rand aussen

difference() {
	Adapter();
	Zugentlastung();          
}

module Adapter() {
	difference() {
		union() {
			// Hauptzylinder
			cylinder(h=sh+1,d=db);
			// Rand herum
			cylinder(h=1,d=db+ra*2);
		}
		
		// Steckergehäuse weg
		translate([-sl/2,-sb/2,0]) cube([sl,sb,sh]);
		// Steckergehäuse Anschlag weg
		translate([-(sl-1)/2,-(sb-1)/2,sh]) cube([sl-1,sb-1,rs]);
	}
}	


module Zugentlastung() {
	// Zugentlastung rausschneiden
	difference() {
		union() {
			// von oben bis zur Biegung
			translate([-zb/2,sb/2+.8,sh-1.4]) cube([zb,zd,3]);
			translate([-zb/2,sb/2+zd+0.8,sh-zd*2]) cube([zb,3.5,zd]);
			color("blue") translate([-zb/2,sb/2+2.3,sh-zd]) cube([zb,zd,zd]);
			intersection() {
				color("blue") translate([-zb/2,sb/2+2.3,sh-zd]) color("red") rotate([0,90,0]) cylinder(h=zb,d=zd*2);
				color("red") translate([-zb/2,sb/2+.8,sh-zd*2]) color("red") cube([zb,zd*2,zd*2]);
			}
		}
		color("red") translate([-zb/2,(sb-1)/2+4.3,sh]) color("red") rotate([0,90,0]) cylinder(h=zb*2,d=zd*2);
	}
	translate([-zb/2,sb/2+.8+zd*2,sh-zd*2]) cube([zb,zd*2,zd+zd*2]);
}



// }
// color("red") {
	// difference() {
		// translate([-12.0/2,7.7/2,9.7]) cube([12.0,4,4]);
		// translate([-9.0/2,7.7/2,9.7]) cube([12.0,4,2]);
	// }
// }



