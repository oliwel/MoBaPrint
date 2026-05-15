

//translate([-2.5,-2.5,-1]) color([1,0,0]) cube([5,5,1]);
//translate([-5,-5,0]) color([0,0,1]) cube([10,10,1]);

difference() {
    translate([-6,0,0]) cube([12,12,5.5]);
    // Ausschnitt LED
    translate([-2.75,3,0]) cube([5.5,9,4.5]);
    // Auschnitt Platine Innen
    translate([-5,1,1]) cube([10,10,3.5]);
    // Einführung Platine
    translate([-5,1,1.5]) cube([10,11,3]);
    // Kabel seitlich
    translate([-6,1,3]) cube([12,12,1.5]);
}

/*

translate([-5,-4.75,-1]) {
    color([0,0,1]) difference() {        
        // Block für LED Gabel
        cube([11,9.5,2]);
        // Ausschnitt LED
        translate([2.5,2,0]) cube([8.5,5.5,2]);
        // Ausschnitt Platine
        translate([0,0,1]) cube([10,9.5,2]);

    }
}

// Wand
color([1,0,0])  translate([-5.5,-4.75,-1]) cube([0.6,9.5,5.5]);
//Deckel
color([0,1,0]) translate([-5,-4.75,3.5]) cube([11,9.5,1]);

/*
translate([0,0,-15.3])
difference() {
    cube([30.6,20.6,30.6], true);
    translate([-0.3,0,0]) cube([30,19.4,29.4], true);
     cube([5.5,5.5,1.6]);
 }*/