// Hausmaske mit Fenster- und Türöffnungen aus CSV-Daten
// Aufruf: python3 server.py --parse sample.csv > house_data.scad
// Dann diese Datei in OpenSCAD öffnen.

include <house_data.scad>

wall_t     = 0.8;   // Wandstärke [mm]
licht_w    = 40;    // Lichtausschnitt Breite [mm]
licht_d    = 35;    // Lichtausschnitt Tiefe [mm]
board_slot = 3;     // Versatz der X-Wand vom Mittelpunkt [mm]
board_cap  = 15;    // Breite der kurzen Querwand [mm]

// licht = [[x, y, rotation], ...]
// x/y = Abstand von links vorne (Außenwand) zur unteren linken Ecke des Ausschnitts

module licht_transform(l) {
    cx = l[0] + licht_w / 2;
    cy = l[1] + licht_d / 2;
    translate([cx, cy, 0])
        rotate([0, 0, l[2]])
            translate([-cx, -cy, 0])
                children();
}

// Alle Öffnungen einer Wand als Subtraktionskörper.
// windows = [[x_start, y_start, x_size, y_size], ...]
// x = Position entlang der Wandlänge (von links außen), y = Höhe ab Boden
module front_cuts(windows) {
    for (w = windows)
        translate([w[0], -0.1, w[1]])
            cube([w[2], wall_t + 0.2, w[3]]);
}
module back_cuts(windows) {
    for (w = windows)
        translate([room_width - w[0] - w[2], room_depth - wall_t - 0.1, w[1]])
            cube([w[2], wall_t + 0.2, w[3]]);
}
module left_cuts(windows) {
    for (w = windows)
        translate([-0.1, room_depth - w[0] - w[2], w[1]])
            cube([wall_t + 0.2, w[2], w[3]]);
}
module right_cuts(windows) {
    for (w = windows)
        translate([room_width - wall_t - 0.1, w[0], w[1]])
            cube([wall_t + 0.2, w[2], w[3]]);
}

// Dachausschnitte: [[x, y, breite, tiefe], ...] – Ursprung vorne links
module dach_cuts() {
    for (d = dach)
        translate([d[0], d[1], room_height - wall_t - 0.1])
            cube([d[2], d[3], wall_t + 0.2]);
}

// Board: Kreuzstruktur für Lichtausschnitt (nutzt globale licht_w, licht_d).
// Koordinatenursprung = vorne links des Boards (licht_x - wall_t, licht_y - wall_t).
module board() {
    bw = licht_w + 2 * wall_t;
    bd = licht_d + 2 * wall_t;
    cx = bw / 2;
    cy = bd / 2;
    h  = room_height - wall_t;

    // X-Wand: volle Breite, board_slot mm von Mitte in +Y
    translate([0, cy + board_slot - wall_t / 2, 0])
        cube([bw, wall_t, h]);

    // Y-Wand: mit Lücke für den Schlitz der X-Wand
    translate([cx - wall_t, 0, 0])
        cube([wall_t, bd / 2 - board_slot, h]);
    translate([cx - wall_t, bd / 2 + board_slot, 0])
        cube([wall_t, bd / 2 - board_slot, h]);

    // kurze Querwand: board_cap mm breit, board_slot mm von Mitte in -Y
    translate([cx - board_cap / 2, cy - board_slot - wall_t / 2, 0])
        cube([board_cap, wall_t, h]);

    // linke Stirnwand
    translate([cx - board_cap / 2 - wall_t, cy - board_slot - wall_t / 2, 0])
        cube([wall_t, 2 * board_slot + wall_t, h]);

    // rechte Stirnwand
    translate([cx + board_cap / 2, cy - board_slot - wall_t / 2, 0])
        cube([wall_t, 2 * board_slot + wall_t, h]);
}

// Wandansatz von Außenwand bis zur Dachöffnungskante,
// dann entlang der Kante zur nächsten Board-Wand.

module walls_from_back(positions, l) {
    cx = l[0] + licht_w / 2;
    ey = l[1] + licht_d;     // hintere Lichtöffnungskante
    for (p = positions) {
        translate([p - wall_t/2, ey, 0])
            cube([wall_t, room_depth - wall_t - ey, room_height]);
        translate([min(p, cx) - wall_t/2, ey, 0])
            cube([abs(p - cx) + wall_t, wall_t, room_height]);
    }
}

module walls_from_front(positions, l) {
    cx = l[0] + licht_w / 2;
    ey = l[1];               // vordere Lichtöffnungskante
    for (p = positions) {
        translate([p - wall_t/2, wall_t, 0])
            cube([wall_t, ey - wall_t, room_height]);
        translate([min(p, cx) - wall_t/2, ey - wall_t, 0])
            cube([abs(p - cx) + wall_t, wall_t, room_height]);
    }
}

module walls_from_left(positions, l) {
    ex = l[0];                              // linke Lichtöffnungskante
    bx = l[1] + licht_d / 2 + board_slot;  // Board X-Wand (Weltkoordinate Y)
    for (p = positions) {
        translate([wall_t, p - wall_t/2, 0])
            cube([ex - wall_t, wall_t, room_height]);
        translate([ex - wall_t, min(p, bx) - wall_t/2, 0])
            cube([wall_t, abs(p - bx) + wall_t, room_height]);
    }
}

module walls_from_right(positions, l) {
    ex = l[0] + licht_w;                   // rechte Lichtöffnungskante
    bx = l[1] + licht_d / 2 + board_slot;  // Board X-Wand (Weltkoordinate Y)
    for (p = positions) {
        translate([ex, p - wall_t/2, 0])
            cube([room_width - wall_t - ex, wall_t, room_height]);
        translate([ex, min(p, bx) - wall_t/2, 0])
            cube([wall_t, abs(p - bx) + wall_t, room_height]);
    }
}

union() {
    // Wände: Hohlbox (Außenhülle minus Innenraum) mit Öffnungen
    difference() {
        cube([room_width, room_depth, room_height]);
        translate([wall_t, wall_t, -0.5])
            cube([
                room_width  - 2 * wall_t,
                room_depth  - 2 * wall_t,
                room_height + 1
            ]);
        front_cuts(front_windows);
        back_cuts(back_windows);
        left_cuts(left_windows);
        right_cuts(right_windows);
        // Wand entfernen wenn keine Fenster definiert
        if (len(front_windows)  == 0)
            translate([-0.1, -0.1, -0.1])
                cube([room_width + 0.2, wall_t + 0.2, room_height + 0.2]);
        if (len(back_windows)   == 0)
            translate([-0.1, room_depth - wall_t - 0.1, -0.1])
                cube([room_width + 0.2, wall_t + 0.2, room_height + 0.2]);
        if (len(left_windows)   == 0)
            translate([-0.1, -0.1, -0.1])
                cube([wall_t + 0.2, room_depth + 0.2, room_height + 0.2]);
        if (len(right_windows)  == 0)
            translate([room_width - wall_t - 0.1, -0.1, -0.1])
                cube([wall_t + 0.2, room_depth + 0.2, room_height + 0.2]);
    }
    // Board für jeden Lichtausschnitt
    for (l = licht)
        licht_transform(l)
            translate([l[0] - wall_t, l[1] - wall_t, 0])
                color([1,0,0])
                    board();
    // Ansatz-Innenwände (referenzieren ersten Lichtausschnitt)
    if (len(licht) > 0)
        color([0.5,0.5,0.8]) {
            walls_from_back(back_wall_pos, licht[0]);
            walls_from_front(front_wall_pos, licht[0]);
            walls_from_left(left_wall_pos, licht[0]);
            walls_from_right(right_wall_pos, licht[0]);
        }
    // Decke mit Lichtausschnitten (kein Boden)
    difference() {
        translate([0, 0, room_height - wall_t])
            cube([room_width, room_depth, wall_t]);
        for (l = licht)
            licht_transform(l)
                translate([l[0], l[1], room_height - wall_t - 0.1])
                    cube([licht_w, licht_d, wall_t + 0.2]);
        dach_cuts();
    }
    // Rand um jeden Lichtausschnitt: Wandstärke breit, 2mm hoch (Innenseite)
    for (l = licht)
        licht_transform(l)
            translate([l[0] - wall_t, l[1] - wall_t, room_height - wall_t - 2])
                difference() {
                    cube([licht_w + 2 * wall_t, licht_d + 2 * wall_t, 2]);
                    translate([wall_t, wall_t, -0.1])
                        cube([licht_w, licht_d, 2.2]);
                }
}
