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
R        = 618;
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

// --- Plattendimensionen -------------------------------------
panel_h  = 1;    // Höhe Bodenplatte [mm]
bar_w    = 1.5;  // Breite X-Diagonalen [mm]
frame_w  = 2.5;  // Breite Rahmen und Mittelstrebe [mm]

// --- Rendersteuerung ----------------------------------------
//  render_seg:  0      = alle 5 Segmente im Bogen
//               1 .. 5 = einzelnes Segment (1-indiziert)
//  print_half:  0 = vollständig
//               1 = linke Druckhälfte  (x ≤ 0, Seg 1+2 + halbes Seg 3)
//               2 = rechte Druckhälfte (x ≥ 0, halbes Seg 3 + Seg 4+5)
render_seg  = 0;
print_half  = 1;
_big        = 2000;   // Hilfsgröße für den Schnittquader

// ============================================================
// Gehrungswinkel-Funktionen (i = 0-basierter Index)
function ml(i) = (i == 0)         ? 0 : hm;
function mr(i) = (i == n_seg - 1) ? 0 : hm;

// ============================================================
// Flacher Balken von p1=[x1,y1] nach p2=[x2,y2] in der XY-Ebene
// Breite w, Höhe h (Z), Balken Y-zentriert auf Verbindungslinie
module balken(p1, p2, w, h) {
    dx = p2[0] - p1[0];
    dy = p2[1] - p1[1];
    L  = sqrt(dx*dx + dy*dy);
    a  = atan2(dy, dx);
    translate([p1[0], p1[1], 0])
    rotate([0, 0, a])
    translate([0, -w/2, 0])
        cube([L, w, h]);
}

module fill_edge(p,w,h) {
    translate([p[0],p[1],h/2]) cube([w, w, h],true);
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

    // Trapez-Eckpunkte
    OL = [-hw * tan(miter_L),          -hw];  // Außen-Links
    IL = [ hw * tan(miter_L),          +hw];  // Innen-Links
    OR = [ seg_L + hw * tan(miter_R),  -hw];  // Außen-Rechts
    IR = [ seg_L - hw * tan(miter_R),  +hw];  // Innen-Rechts

    // Mittelpunkte (Mittelstrebe)
    OM = [seg_L / 2, -hw];
    IM = [seg_L / 2, +hw];

    // 1) Außenrahmen
    color([1,0,0]) {
        balken(OL, IL, frame_w, panel_h);   // linkes Ende
        fill_edge(OL,frame_w, panel_h);        
        balken(IL, IR, frame_w, panel_h);   // Innenkante
        fill_edge(IL,frame_w, panel_h);
        balken(IR, OR, frame_w, panel_h);   // rechtes Ende
        fill_edge(IR,frame_w, panel_h);
        balken(OR, OL, frame_w, panel_h);   // Außenkante        
        fill_edge(OR,frame_w, panel_h);
    }
    
    

    // 2) Mittelstrebe
    color([0,1,0]) balken(OM, IM, frame_w, panel_h);

    // 3) X linke Hälfte
    color([0,0,1]) {
        balken(OL, IM, bar_w, panel_h);
        balken(IL, OM, bar_w, panel_h);

    // 4) X rechte Hälfte
        balken(OM, IR, bar_w, panel_h);
        balken(IM, OR, bar_w, panel_h);
    }
}

// ============================================================
// Alle 5 Segmente im Bogen
// Bogenmittelpunkt bei [0,0,0]; Brücke symmetrisch um 0°
module bodenplatte_gesamt() {
    for (i = [0 : n_seg - 1]) {
        a_start = -bogen/2 + i * ang_seg;
        px      =  R * sin(a_start);
        py      = -R * cos(a_start);
        a_chord = a_start + ang_seg / 2;

        translate([px, py, 0])
        rotate([0, 0, a_chord])
        boden_segment(ml(i), mr(i));
    }
}

// ============================================================
// Schnittquader: schneidet die Geometrie bei x=0 (Bogenmitte)
// Segment 3 liegt symmetrisch um x=0 → saubere Trennkante
module links()  { translate([-_big, -_big, -_big]) cube([_big, 2*_big, 2*_big]); }
module rechts() { translate([    0, -_big, -_big]) cube([_big, 2*_big, 2*_big]); }

// ============================================================
// Render
module _basis() {
    if (render_seg == 0)
        bodenplatte_gesamt();
    else
        boden_segment(ml(render_seg - 1), mr(render_seg - 1));
}

if      (print_half == 1) intersection() { _basis(); links();  }
else if (print_half == 2) intersection() { _basis(); rechts(); }
else                                       _basis();
