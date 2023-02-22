h=23;			//	Anzahl Reihen (Höhe)
n=30;			//	Anzahl Steine pro Umlauf
w=2.2;             // Steinbreite (in h)
l=2.0;             // Steinlänge (entlang Kreisbogen)
t = 1;      // Prägetiefe
pat = 2;    // Anzahl der Zeilen nach denen sich das Muster wiederholt
sp = 0.4;    // Abstand zwischen den Steinen
axis = 6; // Durchmesser des Innenloch
$fn=32;

// Winkel pro Zelle
/*ds=(dw-w)/sin(360/6);
// Kreisdurchmesser
dc=((n*dw)/(2*PI))*2;
dh=dw*sin(360/6);
*/
// Kreisumfang = Anzahl der Steine * Steinlänge + Abstand
cl = n*(l+sp);
// Kreisradius
cr = cl/(2*PI)+t;

// Höhe des Zylinder
ch = h*(w+sp);

// Winkel pro Stein
ia = 360/n;

// Die Form des Stein ist egal, y=0 ist der Schnittpunkt mit der Oberfläche
module rect_stone() {
     // rechteckige steine
     cube([l,t,w],true);
}

module rounded_stone() {
     // abgerundete Steine
     rotate([90,0,0]) translate([0,0,-1]) minkowski(){
        cylinder(1,d=1);
        linear_extrude(height=t, scale=0.6) square([l-1,w-1],true);
    }
    
}

module roller() {
    difference() {
        cylinder(ch, cr, cr);
        color([1,0,0])
        for (hn=[0:h]) {
            translate([0,0,(w+sp)*(hn+0.5)])
            for (rn=[0:pat:n]) {
                
                for (pn=[0:pat-1]) {
                // Der Würfel steckt zur Hälfte im Zylinder
                rotate([0,0,(rn+pn)*ia]) 
                  translate([0,cr-t/2,-pn*(w+sp)/pat])
                    children(0);
                }
            }
        }
        //cylinder(ch, cr-3*t, cr-3*t);
        cylinder(ch, axis/2, axis/2);
    }   
    /*
    difference() {
        union() {
            if (axis > 0) {
                for (spn=[0:2]) {
                    rotate([0,0,spn*60]) 
                        translate([0,0,ch/2]) cube([2*(cr-3*t),3,ch],true);
                }        
                cylinder(ch, axis, axis);
            }
        }
        cylinder(ch, axis/2, axis/2);
    }*/
}

roller() { rounded_stone(); }