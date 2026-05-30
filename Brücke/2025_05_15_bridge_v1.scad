$fn = 16;

// ============================================================
// H0 Bogenbrücke – BODENELEMENTE
// Märklin K-Gleis R5 (618 mm), 40°, 5 Segmente
//
// Jedes Segment = 4 Strukturelemente:
//   1) Trapezförmiger Außenrahmen
//   2) Mittelstrebe (halbiert das Segment)
//   3) X-Aussteifung linke Hälfte
//   4) X-Aussteifung rechte Hälfte
//
// Gehrungswinkel je Verbindungsfuge: 4° (= ang_seg/2)
// Endsegmente (i=0 und i=4): äußeres Ende rechtwinklig (90°)
// ============================================================

// --- Gleisgeometrie -----------------------------------------
R        = 554;
bogen    = 40;
n_seg    = 5;
ang_seg  = bogen / n_seg;             // 8° pro Segment
hm       = ang_seg / 2;               // Gehrungswinkel = 4°
seg_L    = 2 * R * sin(ang_seg / 2);  // Sehnenlänge ≈ 86.2 mm

// --- Querschnitt --------------------------------------------
licht_b  = 36;
d_stab   = 2.5;
aussen_b = licht_b + 2 * d_stab;     // Gesamtbreite ≈ 41 mm
hw       = aussen_b / 2;              // Halbbreite ≈ 20.5 mm

// --- T-Träger-Profil ----------------------------------------
//   Flansch (flache Seite, liegt auf Grundplatte): 4 mm × 0.5 mm
//   Steg (mittig oben):                            2 mm × 1.0 mm
flange_w = 4.0;
flange_h = 0.5;
web_w    = 1.5;
web_h    = 1.0;

// --- Rendersteuerung ----------------------------------------
//  render_from, render_to: Segmentbereich (1-indiziert, inklusiv)
//    1 + 5  →  alle 5 Segmente
//    1 + 2  →  Segmente 1 und 2
//    3 + 3  →  nur Segment 3
//  print_half:  0 = vollständig
//               1 = linke Druckhälfte  (x ≤ 0, Seg 1+2 + halbes Seg 3)
//               2 = rechte Druckhälfte (x ≥ 0, halbes Seg 3 + Seg 4+5)
render_from = 4;
render_to   = 5;
print_half  = 0;
_big        = 2000;   // Hilfsgröße für den Schnittquader

// ============================================================
// Gehrungswinkel-Funktionen – alle Enden mit Gehrung hm = 4°
function ml(i) = hm;
function mr(i) = hm;

// ============================================================
// T-Träger-Balken von p1 nach p2 in der XY-Ebene
//   Flansch (unten): flange_w × flange_h
//   Steg   (oben, zentriert): web_w × web_h
// with_ext = true  → Längsbalken / Diagonalen: Überstand flange_w/2 an jedem Ende
// with_ext = false → Querbalken:               kein Überstand, Enden bündig
module balken(p1, p2, with_ext = true) {
    dx  = p2[0] - p1[0];
    dy  = p2[1] - p1[1];
    L   = sqrt(dx*dx + dy*dy);
    a   = atan2(dy, dx);
    ext = with_ext ? flange_w / 2 : 0;
    translate([p1[0], p1[1], 0])
    rotate([0, 0, a]) {
        translate([-ext, -flange_w/2, 0])
            cube([L + 2*ext, flange_w, flange_h]);
        translate([-ext, -web_w/2, flange_h])
            cube([L + 2*ext, web_w, web_h]);
    }
}

// ============================================================
// Einzelnes Bodensegment
//
// Koordinatensystem (lokal):
//   X  = Längsrichtung (Gleisrichtung), 0 … seg_L
//   Y  = Querrichtung, Gleisachse bei Y = 0
//        Y = −hw : Außenbogen (größerer Radius)
//        Y = +hw : Innenbogen (kleinerer Radius)
//   Z  = aufwärts, Platte von 0 … panel_h
//
// Geometrie der Gehrung:
//   Linkes  Ende: Schnittlinie  x = y · tan(miter_L)
//   Rechtes Ende: Schnittlinie  x = seg_L − y · tan(miter_R)
//   → Innenkante (y=+hw) kürzer, Außenkante (y=−hw) länger ✓
module boden_segment(miter_L, miter_R) {

    // Längsbalken-Mittellinien (Außenrahmen, Diagonalen)
    OL = [-hw * tan(miter_L),          -hw];
    IL = [ hw * tan(miter_L),          +hw];
    OR = [ seg_L + hw * tan(miter_R),  -hw];
    IR = [ seg_L - hw * tan(miter_R),  +hw];

    // Querbalken-Endpunkte: zur Innenfläche der Längsbalken-Flansche verschoben
    // → Querbalken ragen nicht über die Längsbalken-Flansche hinaus
    hw_q = hw - flange_w / 2;
    OL_q = [-hw_q * tan(miter_L), -hw_q];
    IL_q = [ hw_q * tan(miter_L), +hw_q];
    OR_q = [ seg_L + hw_q * tan(miter_R), -hw_q];
    IR_q = [ seg_L - hw_q * tan(miter_R), +hw_q];

    // Mittelpunkte (für Diagonalen an Längsbalken, für Mittelstrebe an Innenfläche)
    OM   = [seg_L / 2, -hw];
    IM   = [seg_L / 2, +hw];
    OM_q = [seg_L / 2, -hw_q];
    IM_q = [seg_L / 2, +hw_q];

    // Schnittpolygon: Trapez um flange_w/2 nach außen erweitert,
    // damit die Flansche der Längsbalken vollständig erhalten bleiben
    // und die Gehrungsenden exakt bündig abgeschnitten werden.
    hw_c = hw + flange_w / 2;
    eOL = [-hw_c * tan(miter_L), -hw_c];
    eIL = [ hw_c * tan(miter_L),  hw_c];
    eIR = [seg_L - hw_c * tan(miter_R),  hw_c];
    eOR = [seg_L + hw_c * tan(miter_R), -hw_c];

    intersection() {
        linear_extrude(flange_h + web_h)
            polygon([eOL, eIL, eIR, eOR]);

        union() {
            // 1a) Längsbalken (Außen- und Innenkante) – mit Überstand
            color([1,0,0]) {
                balken(OR, OL);          // Außenkante
                balken(IL, IR);          // Innenkante
            }
            // 1b) Querbalken (Enden) – Endpunkt an Innenfläche, Überstand reicht bis Mittelline
            color([1,0,0]) {
                balken(OL_q, IL_q);   // linkes Ende
                balken(IR_q, OR_q);   // rechtes Ende
            }
            // 2) Mittelstrebe – dto.
            color([0,1,0]) balken(OM_q, IM_q);
            // 3) X linke Hälfte
            color([0,0,1]) {
                balken(OL_q, IM_q);
                balken(IL_q, OM_q);
            }
            // 4) X rechte Hälfte
            color([0,0,1]) {
                balken(OM_q, IR_q);
                balken(IM_q, OR_q);
            }
        }
    }
}

// ============================================================
// Schnittquader: schneidet die Geometrie bei x=0 (Bogenmitte)
// Segment 3 liegt symmetrisch um x=0 → saubere Trennkante
module links()  { translate([-_big, -_big, -_big]) cube([_big, 2*_big, 2*_big]); }
module rechts() { translate([    0, -_big, -_big]) cube([_big, 2*_big, 2*_big]); }

// ============================================================
// Render: render_from .. render_to (1-indiziert) im Bogen platzieren
module _basis() {
    for (i = [render_from - 1 : render_to - 1]) {
        a_start = -bogen/2 + i * ang_seg;
        px      =  R * sin(a_start);
        py      = -R * cos(a_start);
        a_chord = a_start + ang_seg / 2;

        translate([px, py, 0])
        rotate([0, 0, a_chord])
        boden_segment(ml(i), mr(i));
    }
}

if      (print_half == 1) intersection() { _basis(); links();  }
else if (print_half == 2) intersection() { _basis(); rechts(); }
else                                       _basis();
