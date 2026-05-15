$fn=500;    // zum testen den Wert auf <50 setzen

db  = 20+0.5;   // Durchmesser Bohrung + Toleranz 
br = 30;		// Länge/Breite Grundplatte
ws = 1.2;		// Wandstärke

difference() {
	translate([-br/2,-br/2,0]) cube([br,br,ws]);
	cylinder(h=ws,d=db);
}
