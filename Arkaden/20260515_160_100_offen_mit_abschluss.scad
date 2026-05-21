// ============================================================
//  Mauerplatte mit Arkadenbogen für Modellbahn H0 (1:87)
//  Maße: 180mm breit x 90mm hoch
//  Ziegelmuster im H0-Maßstab + Arkadenbogen in der Mitte
// ============================================================

// --- Hauptmaße der Platte ---
platte_breite  = 160;   // mm
platte_hoehe   =  100;   // mm
platte_tiefe   =   1;   // mm Wandstärke

// --- Ziegelmaße (Realmaß / 87 = H0-Maß) ---
ziegel_breite  =  3.5;  // mm
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
bogen_ry       = 65;    // Halbachse Y = 60mm

// Innen- und Außenradius der Bogensteinreihe
stein_hoehe         = 7;   // mm radialer Überstand (Steinbreite)
stein_tiefe         =  1.2;   // mm Überstand über Plattenoberfläche

// --- Kämpferstein-Maße (global, auch für Pfeiler-Fuß) ---
kaempfer_b = 8;
kaempfer_h = 5;

// --- Abschlusssteine (obere Kante) ---
abschluss_breite     = 12;  // mm Breite je Stein (X)
abschluss_hoehe_soll =  6;  // mm Ziel-Höhe je Stein (Y)

// Unterkante auf nächste Lagerfuge einrasten (n * raster_y)
abschluss_y0    = round((platte_hoehe - abschluss_hoehe_soll) / raster_y) * raster_y;
abschluss_hoehe = platte_hoehe - abschluss_y0;
fuge_grad           =  0.25; // Grad Fugenlücke zwischen Steinen

// Skalierungsfaktor innen/aussen für Ellipse
// Innenkante: Ellipse etwas kleiner, Außenkante: etwas größer
// sodass die Steinreihe stein_hoehe mm breit ist (gemessen radial)
// Wir skalieren beide Achsen gleichmäßig um delta
delta_innen  =  stein_hoehe/2;   // mm — Innenkante der Steine gegenüber Mittellinie
delta_aussen =  stein_hoehe/2;   // mm — Außenkante der Steine gegenüber Mittellinie

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
bogen_segmente = 60;

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
    anzahl_steine = 51;
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

    // ============================================================
    //  Kopfstein (Schlussstein) — genau auf Raster ausgerichtet
    // ============================================================
    // Der Kopfstein sitzt bei 90° (Scheitelpunkt der Ellipse).
    // Er überspannt exakt N Steinraster-Positionen (hier: 3 Steine).
    // Damit er auf Fugengrenzen passt, müssen anzahl_steine ungerade
    // sein und der Kopfstein die mittleren k Steine ersetzen.
    // Bei anzahl_steine=51: Mittelstein = Index 25
    // Kopfstein ersetzt Steine 24, 25, 26 → w_start/w_ende auf
    // exakten Rastergrenzen (ohne fuge_grad-Versatz an den Rändern,
    // da dort die Fugen zu den Nachbarsteinen 23 und 27 liegen).

    kopfstein_anzahl = 3;  // Wie viele Steine ersetzt der Kopfstein?
    kopfstein_mitte  = (anzahl_steine - 1) / 2;  // = 25 bei 51 Steinen
    kopfstein_start_idx = kopfstein_mitte - floor(kopfstein_anzahl / 2);
    kopfstein_ende_idx  = kopfstein_mitte + floor(kopfstein_anzahl / 2);

    // Außengrenzen exakt auf Rasterfugen (= ganzzahlige Vielfache von w_schritt)
    // Innengrenzen haben normalen fuge_grad-Abstand zu den Nachbarsteinen
    kw_start = kopfstein_start_idx * w_schritt + fuge_grad / 2;
    kw_ende  = (kopfstein_ende_idx + 1) * w_schritt - fuge_grad / 2;

    // Kopfstein — rx_aussen/ry_aussen um 1/3 größer als normale Steine
    kopfstein_delta_aussen = delta_aussen * 1.5;
    krx_aussen = bogen_rx + kopfstein_delta_aussen;
    kry_aussen = bogen_ry + kopfstein_delta_aussen;

    kp0 = [ex(kw_start, rx_innen),   ey(kw_start, ry_innen)];
    kp1 = [ex(kw_ende,  rx_innen),   ey(kw_ende,  ry_innen)];
    kp2 = [ex(kw_ende,  krx_aussen), ey(kw_ende,  kry_aussen)];
    kp3 = [ex(kw_start, krx_aussen), ey(kw_start, kry_aussen)];

    translate([bogen_cx, bogen_cy, platte_tiefe - fuge_tiefe - 0.01])
        linear_extrude(height = 1.5 * stein_tiefe + 0.01)
            polygon([kp0, kp1, kp2, kp3]);

}

// ============================================================
//  Modul: Kämpfersteine
// ============================================================
module kaempfersteine() {
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
//  Modul: Abschlusssteine (obere Kante der Platte)
// ============================================================
module abschlusssteine() {
    raster_abs = abschluss_breite + fuge_breite;
    anzahl     = ceil(platte_breite / raster_abs);

    for (i = [0 : anzahl - 1]) {
        x0    = i * raster_abs + fuge_breite;
        x_end = min(x0 + abschluss_breite, platte_breite);

        if (x_end > x0)
            translate([x0,
                       abschluss_y0,
                       platte_tiefe - fuge_tiefe])
                cube([x_end - x0,
                      abschluss_hoehe,
                      2 * stein_tiefe + fuge_tiefe + 0.01]);
    }
}

// ============================================================
//  Pfeiler-Parameter
// ============================================================
pfeiler_breite   = abschluss_breite;  // mm Querschnitt X (= Breite Abschlusssteine)
pfeiler_tiefe    =  6;   // mm Querschnitt Z
pfeiler_z_b      =  5;   // mm Breite Pfeilerstein
pfeiler_z_h      =  2;   // mm Höhe Pfeilerstein
pfeiler_raster_x = pfeiler_z_b + fuge_breite;
pfeiler_raster_y = pfeiler_z_h + fuge_hoehe;

// Ende des letzten vollen Pfeilersteins vor dem Kopfstein
// Raster-Grid startet bei kaempfer_h → letzter vollständiger Stein endet bei:
pfeiler_abschluss_y0 = kaempfer_h
    + floor((abschluss_y0 - kaempfer_h) / pfeiler_raster_y) * pfeiler_raster_y
    + pfeiler_z_h;

// Steinbreite in X auf Pfeilerbreite anpassen: ganzzahlige Teilung, Kanten bündig mit Fuß/Kopf
pfeiler_n_steine     = round((pfeiler_breite + fuge_breite) / pfeiler_raster_x);
pfeiler_z_b_adj      = (pfeiler_breite + fuge_breite) / pfeiler_n_steine - fuge_breite;
pfeiler_raster_x_adj = pfeiler_z_b_adj + fuge_breite;

// ============================================================
//  Modul: Pfeilerziegel-Reihen (wiederverwendet für alle drei Flächen)
//  face: "front" (+Z), "right" (+X), "left" (-X)
// ============================================================
module pfeiler_relief(face) {
    // Vorderseite: angepasste Steinbreite (bündig mit Fuß/Kopf); Seiten: Original
    rx        = (face == "front") ? pfeiler_raster_x_adj : pfeiler_raster_x;
    zb        = (face == "front") ? pfeiler_z_b_adj       : pfeiler_z_b;
    // Grid startet bei kaempfer_h → alle Reihen sind vollständig, kein if-Wrapper nötig
    p_reihen  = ceil((pfeiler_abschluss_y0 - kaempfer_h) / pfeiler_raster_y) + 1;
    span      = (face == "front") ? pfeiler_breite : pfeiler_tiefe;
    p_spalten = ceil(span / rx) + 1;

    for (reihe = [0 : p_reihen - 1]) {
        versatz = (reihe % 2 == 0) ? 0 : rx / 2;
        for (spalte = [0 : p_spalten - 1]) {
            u0 = spalte * rx - versatz;
            y0 = kaempfer_h + reihe * pfeiler_raster_y;  // bündig am Fußstein

            u_start = max(u0, 0);
            u_ende  = min(u0 + zb, span);
            y_ende  = min(y0 + pfeiler_z_h, pfeiler_abschluss_y0);

            if (u_ende > u_start && y_ende > y0) {
                w = u_ende - u_start;
                h = y_ende - y0;
                if (face == "front")
                    translate([u_start, y0, pfeiler_tiefe - fuge_tiefe])
                        cube([w, h, fuge_tiefe + 0.01]);
                else if (face == "right")
                    translate([pfeiler_breite-fuge_tiefe, y0, u_start])
                        cube([fuge_tiefe + 0.01, h, w]);
                else  // left
                    translate([0, y0, u_start])
                        cube([fuge_tiefe + 0.01, h, w]);
            }
        }
    }
}

// ============================================================
//  Modul: Pfeiler
//  Kopf: wie Abschlusssteine der Platte
//  Fuß:  wie Kämpfersteine (kaempfer_h hoch, stein_tiefe Überstand)
// ============================================================
module pfeiler() {
    // Grundkörper
    translate([fuge_tiefe,0,0])
    cube([pfeiler_breite-2*fuge_tiefe, platte_hoehe, pfeiler_tiefe - fuge_tiefe]);

    // Ziegelrelief auf drei Flächen
    pfeiler_relief("front");
    pfeiler_relief("right");
    pfeiler_relief("left");

    // Kopfbereich (bündig mit Abschlusssteinen der Platte: gleicher Z-Überstand)
    translate([0, platte_hoehe-kaempfer_h, 0])
        cube([pfeiler_breite, kaempfer_h, pfeiler_tiefe]);



    // Sockel: solider Block, gleiche Tiefe wie Pfeiler, Höhe = kaempfer_h
    cube([pfeiler_breite, kaempfer_h, pfeiler_tiefe]);
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

            // Abschlusssteine (obere Kante)
            abschlusssteine();
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

mauerplatte();
translate([-pfeiler_breite, 0, 0]) pfeiler();

//difference() {
//translate([-5,40,-10]) cube([400,60,20]);
//translate([40,-5,-10]) cube([400,100,20]);
//}

// ============================================================
//  Hinweise:
//  - Arkadenbogen: Mittellinie Ellipse 140mm x 60mm
//  - Bogensteine als lückenlose Trapez-Polygone (keine Rotation)
//  - Fugen: fuge_grad = 1.5° Winkelabstand
//  - mit_ausschnitt = true/false -> Durchbruch ein-/ausschalten
//  - Druckausrichtung: flach auf dem Drucker-Bett
//  - Empfohlene Schichthöhe: 0.1 mm
// ============================================================
