// ============================================================
//  Mauerplatte mit Arkadenbogen für Modellbahn H0 (1:87)
//  Maße: 180mm breit x 90mm hoch
//  Ziegelmuster im H0-Maßstab + Arkadenbogen in der Mitte
// ============================================================

// --- Hauptmaße der Platte ---
platte_breite  = 160;   // mm
platte_hoehe   =  90;   // mm
platte_tiefe   =   1;   // mm Wandstärke

// --- Ziegelmaße (Realmaß / 87 = H0-Maß) ---
ziegel_breite  =  4;  // mm
ziegel_hoehe   =  0.9; // mm
fuge_breite    =  0.3;  // mm  Stoßfuge (senkrecht)
fuge_hoehe     =  0.3;  // mm  Lagerfuge (waagerecht)
fuge_tiefe     =  0.4;  // mm  Eintiefung der Fuge

// --- Berechnete Rastermaße ---
raster_x = ziegel_breite + fuge_breite;
raster_y = ziegel_hoehe  + fuge_hoehe;

anzahl_reihen  = ceil(platte_hoehe  / raster_y) + 1;
anzahl_spalten = ceil(platte_breite / raster_x) + 2;

// ============================================================
//  Arkadenbogen-Parameter
// ============================================================

bogen_cx       = platte_breite / 2;
bogen_cy       = 0;
bogen_rx       = 70;    // Halbachse X = 140mm/2
bogen_ry       = 60;    // Halbachse Y = 60mm

// Innen- und Außenradius der Bogensteinreihe
stein_hoehe         = 10;   // mm radialer Überstand (Steinbreite)
stein_tiefe         =  1.2;   // mm Überstand über Plattenoberfläche
fuge_grad           =  0.25; // Grad Fugenlücke zwischen Steinen

// Skalierungsfaktor innen/aussen für Ellipse
// Innenkante: Ellipse etwas kleiner, Außenkante: etwas größer
// sodass die Steinreihe stein_hoehe mm breit ist (gemessen radial)
// Wir skalieren beide Achsen gleichmäßig um delta
delta_innen  =  5;   // mm — Innenkante der Steine gegenüber Mittellinie
delta_aussen =  5;   // mm — Außenkante der Steine gegenüber Mittellinie

rx_innen  = bogen_rx  - delta_innen;
ry_innen  = bogen_ry  - delta_innen;
rx_aussen = bogen_rx  + delta_aussen;
ry_aussen = bogen_ry  + delta_aussen;

// Öffnung (Durchbruch): gleich der Innenellipse
oeffnung_rx = rx_innen;
oeffnung_ry = ry_innen;

// *** Ausschnitt aktiv? true = Durchbruch vorhanden, false = nur Relief ***
mit_ausschnitt = true;

// Auflösung
bogen_segmente = 120;

// ============================================================
//  Hilfsfunktionen
// ============================================================
function ex(w, rx) = rx * cos(w);
function ey(w, ry) = ry * sin(w);

// ============================================================
//  Modul: Bogen-Öffnung 2D
// ============================================================
module bogen_oeffnung_2d(rx, ry) {
    polygon(concat(
        [for (i = [0 : bogen_segmente])
            [ex(i * 180 / bogen_segmente, rx),
             ey(i * 180 / bogen_segmente, ry)]],
        [[0, 0]]
    ));
}

// ============================================================
//  Modul: Arkadensteine als lückenlose Trapez-Polygone
//
//  Jeder Stein wird aus 4 Punkten aufgebaut:
//    - 2 Punkte auf der Innenellipse  (Winkel w_start..w_ende)
//    - 2 Punkte auf der Außenellipse  (gleiche Winkel, gespiegelt)
//  → kein Rotations-Trick nötig, Fugen entstehen durch
//    schmalen Winkelabstand (fuge_grad) an den Steinrändern
// ============================================================
module arkadensteine() {
    anzahl_steine = 31;
    w_schritt = 180 / anzahl_steine;  // Winkelbreite pro Stein

    for (i = [0 : anzahl_steine - 1]) {
        w_start = i       * w_schritt + fuge_grad / 2;
        w_ende  = (i + 1) * w_schritt - fuge_grad / 2;

        // 4 Eckpunkte des Trapez-Steins in 2D
        p0 = [ex(w_start, rx_innen),  ey(w_start, ry_innen)];
        p1 = [ex(w_ende,  rx_innen),  ey(w_ende,  ry_innen)];
        p2 = [ex(w_ende,  rx_aussen), ey(w_ende,  ry_aussen)];
        p3 = [ex(w_start, rx_aussen), ey(w_start, ry_aussen)];

        translate([bogen_cx, bogen_cy, platte_tiefe - fuge_tiefe - 0.01])
            linear_extrude(height = stein_tiefe + 0.01)
                polygon([p0, p1, p2, p3]);
    }
}

// ============================================================
//  Modul: Kämpfersteine
// ============================================================
module kaempfersteine() {
    kaempfer_b = 8;
    kaempfer_h = 5;

    // Rechter Kämpfer (Fußpunkt der Ellipse bei 0°)
    translate([bogen_cx + bogen_rx - kaempfer_b / 2,
               bogen_cy,
               platte_tiefe - 0.01])
        cube([kaempfer_b, kaempfer_h, stein_tiefe + 0.01]);

    // Linker Kämpfer (Fußpunkt bei 180°)
    translate([bogen_cx - bogen_rx - kaempfer_b / 2,
               bogen_cy,
               platte_tiefe - 0.01])
        cube([kaempfer_b, kaempfer_h, stein_tiefe + 0.01]);
}

// ============================================================
//  Modul: Mauerplatte
// ============================================================
module mauerplatte() {
    difference() {
        union() {
            // Grundkörper
            cube([platte_breite, platte_hoehe, platte_tiefe-fuge_tiefe]);

            // Ziegelrelief
            for (reihe = [0 : anzahl_reihen - 1]) {
                versatz = (reihe % 2 == 0) ? 0 : raster_x / 2;
                for (spalte = [0 : anzahl_spalten - 1]) {
                    x0 = spalte * raster_x - versatz;
                    y0 = reihe  * raster_y;

                    if (x0 + ziegel_breite > 0 && x0 < platte_breite &&
                        y0 + ziegel_hoehe  > 0 && y0 < platte_hoehe) {

                        x_start = max(x0, 0);
                        y_start = max(y0, 0);
                        x_ende  = min(x0 + ziegel_breite, platte_breite);
                        y_ende  = min(y0 + ziegel_hoehe,  platte_hoehe);

                        if (x_ende > x_start && y_ende > y_start) {
                            translate([x_start, y_start, platte_tiefe - fuge_tiefe])
                                cube([x_ende - x_start,
                                      y_ende - y_start,
                                      fuge_tiefe + 0.01]);
                        }
                    }
                }
            }

            // Arkadensteine
            arkadensteine();

            // Kämpfersteine
            kaempfersteine();
        }

        // Bogen-Öffnung (optional)
        if (mit_ausschnitt) {
            translate([bogen_cx, bogen_cy, -0.1])
                linear_extrude(height = platte_tiefe + stein_tiefe + 0.2)
                    bogen_oeffnung_2d(oeffnung_rx, oeffnung_ry);
        }
    }
}

// ============================================================
//  Rendering
// ============================================================

difference() {mauerplatte();
//translate([-5,40,-10]) cube([400,60,20]);
translate([40,-5,-10]) cube([400,100,20]);
}

// ============================================================
//  Hinweise:
//  - Arkadenbogen: Mittellinie Ellipse 140mm x 60mm
//  - Bogensteine als lückenlose Trapez-Polygone (keine Rotation)
//  - Fugen: fuge_grad = 1.5° Winkelabstand
//  - mit_ausschnitt = true/false -> Durchbruch ein-/ausschalten
//  - Druckausrichtung: flach auf dem Drucker-Bett
//  - Empfohlene Schichthöhe: 0.1 mm
// ============================================================
