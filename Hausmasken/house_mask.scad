// Hausmaske mit Fenster- und Türöffnungen aus CSV-Daten
// Aufruf: python3 parse_house.py sample.csv > house_data.scad
// Dann diese Datei in OpenSCAD öffnen.

include <house_data.scad>

wall_t     = 1;   // Wandstärke [mm]
licht_w    = 40;  // Dachausschnitt Breite [mm]
licht_d    = 35;  // Dachausschnitt Tiefe [mm]
board_slot = 3;   // Versatz der X-Wand vom Mittelpunkt [mm]
board_cap  = 15;  // Breite der kurzen Querwand [mm]

licht_x = (room_width - licht_w) / 2 + licht_offset[0];
licht_y = (room_depth - licht_d) / 2 + licht_offset[1];

licht_cx = licht_x + licht_w / 2;
licht_cy = licht_y + licht_d / 2;

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
        translate([w[0], room_depth - wall_t - 0.1, w[1]])
            cube([w[2], wall_t + 0.2, w[3]]);
}
module left_cuts(windows) {
    for (w = windows)
        translate([-0.1, w[0], w[1]])
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
        translate([d[0], d[1], room_height - 0.1])
            cube([d[2], d[3], wall_t + 0.2]);
}

// Board: Kreuzstruktur zentriert auf den Dachausschnitt.
// Koordinatenursprung = vorne links des Boards (licht_x - wall_t, licht_y - wall_t).
module board() {
    bw = licht_w + 2 * wall_t;
    bd = licht_d + 2 * wall_t;
    cx = bw / 2;
    cy = bd / 2;

    // X-Wand: volle Breite, board_slot mm von Mitte in +Y
    translate([0, cy + board_slot - wall_t / 2, 0])
        cube([bw, wall_t, room_height]);

    // Y-Wand: volle Tiefe, mittig in X
    translate([cx - wall_t , 0, 0])
        cube([wall_t, bd / 2 - board_slot, room_height]);

    translate([cx - wall_t , bd/2 + board_slot , 0])
        cube([wall_t, bd / 2 - board_slot, room_height]);


    // kurze Querwand: board_cap mm breit, board_slot mm von Mitte in -Y
    translate([cx - board_cap / 2, cy - board_slot - wall_t / 2, 0])
        cube([board_cap, wall_t, room_height]);

    // linke Stirnwand
    translate([cx - board_cap / 2 - wall_t, cy - board_slot - wall_t / 2, 0])
        cube([wall_t, 2 * board_slot + wall_t, room_height]);

    // rechte Stirnwand
    translate([cx + board_cap / 2, cy - board_slot - wall_t / 2, 0])
        cube([wall_t, 2 * board_slot + wall_t, room_height]);
}

// Wandansatz von Außenwand bis zur Dachöffnungskante,
// dann entlang der Kante zur nächsten Board-Wand.

module walls_from_back(positions) {
    ey = licht_y + licht_d;  // hintere Lichtöffnungskante
    for (p = positions) {
        // senkrecht: Außenwand → Lichtöffnungskante
        translate([p - wall_t/2, ey, 0])
            cube([wall_t, room_depth - wall_t - ey, room_height]);
        // entlang Kante: p → Board Y-Wand (licht_cx)
        translate([min(p, licht_cx) - wall_t/2, ey, 0])
            cube([abs(p - licht_cx) + wall_t, wall_t, room_height]);
    }
}

module walls_from_front(positions) {
    ey = licht_y;  // vordere Lichtöffnungskante
    for (p = positions) {
        // senkrecht: Außenwand → Lichtöffnungskante
        translate([p - wall_t/2, wall_t, 0])
            cube([wall_t, ey - wall_t, room_height]);
        // entlang Kante: p → Board Y-Wand (licht_cx)
        translate([min(p, licht_cx) - wall_t/2, ey - wall_t, 0])
            cube([abs(p - licht_cx) + wall_t, wall_t, room_height]);
    }
}

module walls_from_left(positions) {
    ex = licht_x;  // linke Lichtöffnungskante
    bx = licht_cy + board_slot;  // Board X-Wand (Weltkoordinate Y)
    for (p = positions) {
        // senkrecht: Außenwand → Lichtöffnungskante
        translate([wall_t, p - wall_t/2, 0])
            cube([ex - wall_t, wall_t, room_height]);
        // entlang Kante: p → Board X-Wand
        translate([ex - wall_t, min(p, bx) - wall_t/2, 0])
            cube([wall_t, abs(p - bx) + wall_t, room_height]);
    }
}

module walls_from_right(positions) {
    ex = licht_x + licht_w;  // rechte Lichtöffnungskante
    bx = licht_cy + board_slot;  // Board X-Wand (Weltkoordinate Y)
    for (p = positions) {
        // senkrecht: Außenwand → Lichtöffnungskante
        translate([ex, p - wall_t/2, 0])
            cube([room_width - wall_t - ex, wall_t, room_height]);
        // entlang Kante: p → Board X-Wand
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
    // Board im Dachausschnitt zentriert
    translate([licht_x - wall_t, licht_y - wall_t, 0])
        board();
    // Ansatz-Innenwände von den Außenwänden
    walls_from_back(back_wall_pos);
    walls_from_front(front_wall_pos);
    walls_from_left(left_wall_pos);
    walls_from_right(right_wall_pos);
    // Decke mit Lichtausschnitt (kein Boden)
    difference() {
        translate([0, 0, room_height])
            cube([room_width, room_depth, wall_t]);
        translate([licht_x, licht_y, room_height - 0.1])
            cube([licht_w, licht_d, wall_t + 0.2]);
        dach_cuts();
    }
}
