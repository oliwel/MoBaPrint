h=16;		//	Anzahl Reihen (Höhe)
n=15;		//	Anzahl Steine pro Umlauf
w=3.15;     // Steinbreite (in h)
l=3.25;      // Steinlänge (entlang Kreisbogen)
t = 1.5;      // Prägetiefe
pat = 3;    // Anzahl der Zeilen nach denen sich das Muster wiederholt
sp = 0.6;   // Abstand zwischen den Steinen
axis = 15;   // Durchmesser des Innenloch
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
    outrim= 2+rands(-0.25,0.25,1)[0];
    rot = rands(-7.5,7.5,1)[0];
    rotate([90,rot,0]) translate([0,0,-1]) minkowski(){
        cylinder(1,d=outrim);
        linear_extrude(height=t, scale=0.6) square([l-outrim,w-outrim],true);    
    }

}

module random_stone() {
     // abgerundete Steine
    random_vect=rands(-0.1,0.1,8);
    rim = 1.40;
    coords = [
        [ 0 + random_vect[0]*w + rim, 0 + random_vect[1]*l + rim ],
        [ w + random_vect[2]*w - rim, 0 + random_vect[3]*l + rim ],
        [ w + random_vect[4]*w - rim, l + random_vect[5]*l - rim ],
        [ 0 + random_vect[6]*w + rim, l + random_vect[7]*l - rim ],
    ];
    rotate([90,0,0]) translate([0,-(h+sp)/2+0.125,-1]) minkowski(){
        cylinder(1,d=2.3);
        linear_extrude(1) polygon(coords);
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
}


module hroller() {
    difference() {
        cylinder(ch, cr, cr);
        color([1,0,0])
        for (hn=[0:h]) {
            translate([0,0,(w+sp)*(hn+0.5)])            
            for (rn=[0:n]) {            
                // Der Würfel steckt zur Hälfte im Zylinder
                rotate([0,0,(rn+hn/pat)*ia]) 
                  translate([0,cr-t/2,0])
                    children(0);
            }        
        }
        //cylinder(ch, cr-3*t, cr-3*t);
        cylinder(ch, axis/2, axis/2);
    }      
}


hroller() { rounded_stone(); }