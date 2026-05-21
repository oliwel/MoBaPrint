// ============================================================
//  Mauerplatte mit Arkadenbogen für Modellbahn H0 (1:87)
//  Variante: 40mm senkrechter Pfeiler + 120°-Arkadenbogen
//  Gesamthöhe: 100mm
// ============================================================

// --- Hauptmaße der Platte ---
platte_breite  = 160;
platte_hoehe   = 100;
platte_tiefe   =   1;

// --- Ziegelmaße ---
ziegel_breite  =  3.5;
ziegel_hoehe   =  0.9;
fuge_breite    =  0.3;
fuge_hoehe     =  0.3;
fuge_tiefe     =  0.4;

raster_x = ziegel_breite + fuge_breite;
raster_y = ziegel_hoehe  + fuge_hoehe;

anzahl_reihen  = ceil(platte_hoehe  / raster_y) + 1;
anzahl_spalten = ceil(platte_breite / raster_x) + 2;

// --- Abschlusssteine ---
abschluss_breite     = 12;
abschluss_hoehe_soll =  6;
abschluss_y0    = round((platte_hoehe - abschluss_hoehe_soll) / raster_y) * raster_y;
abschluss_hoehe = platte_hoehe - abschluss_y0;

// ============================================================
//  Arkadenbogen-Parameter
// ============================================================

pfeiler_h_gerade = 35;    // mm  senkrechter Abschnitt der Öffnung

bogen_cx      = platte_breite / 2;
bogen_rx      =  70;      // Halbachse X
bogen_ry      =  65;      // Halbachse Y

bogen_winkel     = 120;   // Grad  Gesamtwinkel des Bogens (zentriert bei 90°)
bogen_start_deg  = (180 - bogen_winkel) / 2;  // = 30°

stein_hoehe  =  7;        // mm radialer Überstand (Steinbreite)
stein_tiefe  =  1.2;      // mm Überstand über Plattenoberfläche
fuge_grad    =  0.25;     // Grad Fugenlücke zwischen Steinen

kaempfer_b   =  8;
kaempfer_h   =  5;

delta_innen  = stein_hoehe / 2;
delta_aussen = stein_hoehe / 2;

rx_innen  = bogen_rx - delta_innen;
ry_innen  = bogen_ry - delta_innen;
rx_aussen = bogen_rx + delta_aussen;
ry_aussen = bogen_ry + delta_aussen;

oeffnung_rx = rx_innen;
oeffnung_ry = ry_innen;

// X-Positionen der senkrechten Öffnungsränder
oeffnung_x_links  = bogen_cx - oeffnung_rx * cos(bogen_start_deg);
oeffnung_x_rechts = bogen_cx + oeffnung_rx * cos(bogen_start_deg);

// Bogenmitte so legen, dass die innere Sprungkante bei pfeiler_h_gerade liegt:
//   bogen_cy + ry_innen * sin(bogen_start_deg) = pfeiler_h_gerade
bogen_cy = pfeiler_h_gerade - ry_innen * sin(bogen_start_deg);

// Kämpfer-Y: Mittellinie der Bogensteine am Sprungpunkt
kaempfer_y = bogen_cy + bogen_ry * sin(bogen_start_deg);

mit_ausschnitt = true;
bogen_segmente = 60;


// ============================================================
//  Hilfsfunktionen
// ============================================================
function ex(w, rx) = rx * cos(w);
function ey(w, ry) = ry * sin(w);

// ============================================================
//  Modul: Gesamtöffnung 2D
//  Ursprung (0,0) = Unterkante der Öffnung (Weltkoord. Y=0)
//  rx, ry   = innere Öffnungsellipse
//  cy_local = Y-Position der Bogenmitte im Modul-KS (= bogen_cy)
//  start_deg = Bogenstartwinkel (= bogen_start_deg)
// ============================================================
module oeffnung_komplett_2d(rx, ry, cy_local, start_deg) {
    end_deg  = 180 - start_deg;
    h_spring = cy_local + ry * sin(start_deg);  // Y des Sprungpunkts

    // Senkrechter Rechteck-Teil
    translate([-rx * cos(start_deg), 0])
        square([2 * rx * cos(start_deg), h_spring]);

    // Bogensegment als Sektor (Mittelpunkt + Bogenpunkte)
    translate([0, cy_local])
        polygon(concat(
            [for (i = [0 : bogen_segmente])
                let(w = start_deg + i * (end_deg - start_deg) / bogen_segmente)
                [rx * cos(w), ry * sin(w)]],
            [[0, 0]]   // Sektormittelpunkt
        ));
}

// ============================================================
//  Modul: Arkadensteine (120°-Segment: bogen_start_deg … 180°-bogen_start_deg)
// ============================================================
module arkadensteine() {
    anzahl_steine = 51;
    w_schritt = bogen_winkel / anzahl_steine;

    for (i = [0 : anzahl_steine - 1]) {
        w_start = bogen_start_deg + i       * w_schritt + fuge_grad / 2;
        w_ende  = bogen_start_deg + (i + 1) * w_schritt - fuge_grad / 2;

        p0 = [ex(w_start, rx_innen),  ey(w_start, ry_innen)];
        p1 = [ex(w_ende,  rx_innen),  ey(w_ende,  ry_innen)];
        p2 = [ex(w_ende,  rx_aussen), ey(w_ende,  ry_aussen)];
        p3 = [ex(w_start, rx_aussen), ey(w_start, ry_aussen)];

        translate([bogen_cx, bogen_cy, platte_tiefe - fuge_tiefe - 0.01])
            linear_extrude(height = stein_tiefe + 0.01)
                polygon([p0, p1, p2, p3]);
    }

    // Schlussstein (Scheitelpunkt bei 90°)
    kopfstein_anzahl    = 3;
    kopfstein_mitte     = (anzahl_steine - 1) / 2;
    kopfstein_start_idx = kopfstein_mitte - floor(kopfstein_anzahl / 2);
    kopfstein_ende_idx  = kopfstein_mitte + floor(kopfstein_anzahl / 2);

    kw_start = bogen_start_deg + kopfstein_start_idx * w_schritt + fuge_grad / 2;
    kw_ende  = bogen_start_deg + (kopfstein_ende_idx + 1) * w_schritt - fuge_grad / 2;

    krx_aussen = bogen_rx + delta_aussen * 1.5;
    kry_aussen = bogen_ry + delta_aussen * 1.5;

    kp0 = [ex(kw_start, rx_innen),   ey(kw_start, ry_innen)];
    kp1 = [ex(kw_ende,  rx_innen),   ey(kw_ende,  ry_innen)];
    kp2 = [ex(kw_ende,  krx_aussen), ey(kw_ende,  kry_aussen)];
    kp3 = [ex(kw_start, krx_aussen), ey(kw_start, kry_aussen)];

    translate([bogen_cx, bogen_cy, platte_tiefe - fuge_tiefe - 0.01])
        linear_extrude(height = 1.5 * stein_tiefe + 0.01)
            polygon([kp0, kp1, kp2, kp3]);
}

// ============================================================
//  Modul: Kämpfersteine (am Sprungpunkt des 120°-Bogens)
// ============================================================
module kaempfersteine() {
    // Rechter Sprungpunkt (bei bogen_start_deg = 30°)
    translate([bogen_cx + bogen_rx * cos(bogen_start_deg) - kaempfer_b / 2,
               kaempfer_y,
               platte_tiefe - 0.01])
        cube([kaempfer_b, kaempfer_h, stein_tiefe + 0.01]);

    // Linker Sprungpunkt (bei 180° - bogen_start_deg = 150°)
    translate([bogen_cx - bogen_rx * cos(bogen_start_deg) - kaempfer_b / 2,
               kaempfer_y,
               platte_tiefe - 0.01])
        cube([kaempfer_b, kaempfer_h, stein_tiefe + 0.01]);
}

// ============================================================
//  Modul: Abschlusssteine
// ============================================================
module abschlusssteine() {
    raster_abs = abschluss_breite + fuge_breite;
    anzahl     = ceil(platte_breite / raster_abs);

    for (i = [0 : anzahl - 1]) {
        x0    = i * raster_abs + fuge_breite;
        x_end = min(x0 + abschluss_breite, platte_breite);

        if (x_end > x0)
            translate([x0, abschluss_y0, platte_tiefe - fuge_tiefe])
                cube([x_end - x0,
                      abschluss_hoehe,
                      2 * stein_tiefe + fuge_tiefe + 0.01]);
    }
}

// ============================================================
//  Pfeiler-Parameter
// ============================================================
pfeiler_breite   = abschluss_breite;
pfeiler_tiefe    =  6;
pfeiler_z_b      =  5;
pfeiler_z_h      =  2;
pfeiler_raster_x = pfeiler_z_b + fuge_breite;
pfeiler_raster_y = pfeiler_z_h + fuge_hoehe;

pfeiler_abschluss_y0 = kaempfer_h
    + floor((abschluss_y0 - kaempfer_h) / pfeiler_raster_y) * pfeiler_raster_y
    + pfeiler_z_h;

pfeiler_n_steine     = round((pfeiler_breite + fuge_breite) / pfeiler_raster_x);
pfeiler_z_b_adj      = (pfeiler_breite + fuge_breite) / pfeiler_n_steine - fuge_breite;
pfeiler_raster_x_adj = pfeiler_z_b_adj + fuge_breite;

// ============================================================
//  Modul: Pfeilerziegel-Reihen
// ============================================================
module pfeiler_relief(face, max_brick_y = pfeiler_abschluss_y0) {
    rx        = (face == "front") ? pfeiler_raster_x_adj : pfeiler_raster_x;
    zb        = (face == "front") ? pfeiler_z_b_adj       : pfeiler_z_b;
    p_reihen  = ceil((max_brick_y - kaempfer_h) / pfeiler_raster_y) + 1;
    span      = (face == "front") ? pfeiler_breite : pfeiler_tiefe;
    p_spalten = ceil(span / rx) + 1;

    for (reihe = [0 : p_reihen - 1]) {
        versatz = (reihe % 2 == 0) ? 0 : rx / 2;
        for (spalte = [0 : p_spalten - 1]) {
            u0 = spalte * rx - versatz;
            y0 = kaempfer_h + reihe * pfeiler_raster_y;

            u_start = max(u0, 0);
            u_ende  = min(u0 + zb, span);
            y_ende  = min(y0 + pfeiler_z_h, max_brick_y);

            if (u_ende > u_start && y_ende > y0) {
                w = u_ende - u_start;
                h = y_ende - y0;
                if (face == "front")
                    translate([u_start, y0, pfeiler_tiefe - fuge_tiefe])
                        cube([w, h, fuge_tiefe + 0.01]);
                else if (face == "right")
                    translate([pfeiler_breite - fuge_tiefe, y0, u_start])
                        cube([fuge_tiefe + 0.01, h, w]);
                else
                    translate([0, y0, u_start])
                        cube([fuge_tiefe + 0.01, h, w]);
            }
        }
    }
}

// ============================================================
//  Modul: Pfeiler
// ============================================================
module pfeiler() {
    translate([fuge_tiefe, 0, 0])
        cube([pfeiler_breite - 2 * fuge_tiefe, platte_hoehe, pfeiler_tiefe - fuge_tiefe]);

    pfeiler_relief("front");
    pfeiler_relief("right");
    pfeiler_relief("left");

    translate([0, platte_hoehe - kaempfer_h, 0])
        cube([pfeiler_breite, kaempfer_h, pfeiler_tiefe]);

    cube([pfeiler_breite, kaempfer_h, pfeiler_tiefe]);
}

// ============================================================
//  Modul: Mauerplatte
// ============================================================
module mauerplatte() {
    difference() {
        union() {
            cube([platte_breite, platte_hoehe, platte_tiefe - fuge_tiefe]);

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

                        if (x_ende > x_start && y_ende > y_start)
                            translate([x_start, y_start, platte_tiefe - fuge_tiefe])
                                cube([x_ende - x_start,
                                      y_ende - y_start,
                                      fuge_tiefe + 0.01]);
                    }
                }
            }

            arkadensteine();
            //kaempfersteine();
            abschlusssteine();
        }

        if (mit_ausschnitt) {
            translate([bogen_cx, 0, -0.1])
                linear_extrude(height = platte_tiefe + stein_tiefe + 0.2)
                    oeffnung_komplett_2d(oeffnung_rx, oeffnung_ry,
                                         bogen_cy, bogen_start_deg);
        }
    }
}

// ============================================================
//  Modul: Bogenpfeiler (senkrechte Laibungssteine, Fortsetzung der Arkadensteine)
// ============================================================
module bogenpfeiler() {
    // Horizontale Breite = Projektion des radialen Überhangs am Sprungwinkel
    j_breite = stein_hoehe * cos(bogen_start_deg);

    anzahl_j = round(pfeiler_h_gerade / (stein_hoehe/2 + fuge_hoehe));
    j_raster = pfeiler_h_gerade / anzahl_j;
    j_hoehe  = j_raster - fuge_hoehe;

    for (i = [0 : anzahl_j]) {
        y0 = i * j_raster;

        translate([oeffnung_x_rechts, y0, platte_tiefe - fuge_tiefe - 0.01])
            cube([j_breite, j_hoehe, stein_tiefe + 0.01]);

        translate([oeffnung_x_links - j_breite, y0, platte_tiefe - fuge_tiefe - 0.01])
            cube([j_breite, j_hoehe, stein_tiefe + 0.01]);
    }

    // Abschlussstein am Übergang senkrecht → Bogen
    translate([oeffnung_x_rechts, pfeiler_h_gerade, platte_tiefe - fuge_tiefe - 0.01])
        cube([kaempfer_b, j_hoehe, stein_tiefe + 0.01]);

    translate([oeffnung_x_links - kaempfer_b, pfeiler_h_gerade, platte_tiefe - fuge_tiefe - 0.01])
        cube([kaempfer_b, j_hoehe, stein_tiefe + 0.01]);
}

// ============================================================
//  Rendering
// ============================================================

mauerplatte();
translate([-pfeiler_breite, 0, 0]) pfeiler();
bogenpfeiler();
