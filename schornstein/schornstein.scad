// ============================================================
// Schornstein für H0-Modellbahn (Maßstab 1:87)
// Parametrisches 3D-Druck-Modell mit Ziegeloptik
// Druck als einzelne Segmente mit Trennringen dazwischen
// ============================================================

/* [Hauptmaße] */
// Außendurchmesser des Schornsteins am unteren Ende in mm
aussen_durchmesser = 50;
// Außendurchmesser des Schornsteins am oberen Ende in mm (kleiner = Verjüngung nach oben)
aussen_durchmesser_oben = 35;
// Wandstärke in mm
wandstaerke = 2.0;
// Gesamthöhe des Schornsteins in mm (alle Segmente zusammen, ohne Ringe)
gesamt_hoehe = 400;
// Höhe je Druck-Segment in mm
segment_hoehe = 50;

/* [Trennringe] */
// Sichtbare Höhe des Trennrings (Bund) in mm
ring_hoehe = 2.5;
// Wie viel größer der Ringdurchmesser gegenüber dem Schornstein ist (mm, auf den Durchmesser gerechnet)
ring_ueberstand = 0.6;
// Tiefe, mit der der Ring-Steckzapfen in die Innenbohrung der Segmente greift (mm)
zapfen_hoehe = 3.0;
// Spiel zwischen Zapfen und Bohrung, damit es steckbar ist (mm)
spiel = 0.15;

/* [Ziegeloptik] */
// Höhe einer Ziegelreihe in mm
ziegel_hoehe = 2.2;
// Ziel-Länge eines Ziegels in mm (wird an den Umfang angepasst)
ziegel_laenge = 4.5;
// Breite der Mörtelfuge in mm
fugen_breite = 0.5;
// Wie weit der Ziegel gegenüber der Fugenebene vorsteht (mm)
relief_tiefe = 0.35;

/* [Druck-Layout] */
// Abstand zwischen den Teilen auf der Druckplatte in mm
plate_abstand = 6;
// "layout" = liegende Einzelteile für den Druck, "assembled" = zusammengesteckte Vorschau (nur zur Kontrolle)
ansicht = "assembled"; // ["layout", "assembled"]

/* [Auflösung] */
kreis_facetten = 96;

// ============================================================
// Abgeleitete Werte
// ============================================================
$fn = kreis_facetten;

ring_aussen_durchmesser_max = aussen_durchmesser + ring_ueberstand;

anzahl_segmente = ceil(gesamt_hoehe / segment_hoehe);
letzte_segment_hoehe = gesamt_hoehe - (anzahl_segmente - 1) * segment_hoehe;

function segment_h(i) = (i == anzahl_segmente - 1) ? letzte_segment_hoehe : segment_hoehe;

// Kumulierte Höhe aller Segmente vor Segment i (ohne Ringe)
function segmente_summe(i) = (i <= 0) ? 0 : segmente_summe(i - 1) + segment_h(i - 1);

// Position (z) von Segment i im zusammengesteckten Schornstein, inkl. aller Ringe davor
function segment_z_start(i) = segmente_summe(i) + i * ring_hoehe;

// Gesamthöhe inkl. Trennringe -> Bezugsgröße für die Verjüngung
hoehe_mit_ringen = gesamt_hoehe + (anzahl_segmente - 1) * ring_hoehe;

// Außendurchmesser an einer bestimmten Höhe z im zusammengesteckten Schornstein (lineare Verjüngung)
function aussen_d_bei(z) = aussen_durchmesser - (aussen_durchmesser - aussen_durchmesser_oben) * (z / hoehe_mit_ringen);

echo(str("Segmente: ", anzahl_segmente, " Stück | letztes Segment: ", letzte_segment_hoehe, " mm hoch"));
echo(str("Trennringe: ", anzahl_segmente - 1, " Stück"));

// ============================================================
// Ziegeloptik: einzelner Ziegel als radialer Klotz, der über den
// Grundzylinder hinaussteht (kein Überhang -> gut druckbar)
// ============================================================
module ziegel_stein(aussen_d, winkel_breite, hoehe, tiefe) {
    r = aussen_d / 2;
    breite_sehne = 2 * r * sin(winkel_breite / 2) * 0.92;
    rotate([0, 0, -winkel_breite / 2])
        translate([r - tiefe / 2, 0, 0])
        cube([tiefe, breite_sehne, hoehe], center = true);
}

// Kegelstumpf mit Ziegel-Reliefstruktur im laufenden Verband (versetzte Reihen).
// d_unten/d_oben erlauben eine Verjüngung des Durchmessers über die Höhe.
module ziegeloptik(hoehe, d_unten, d_oben) {
    d_mitte = (d_unten + d_oben) / 2;
    umfang = PI * d_mitte;
    reihen = max(1, round(hoehe / ziegel_hoehe));
    reihen_hoehe = hoehe / reihen;
    spalten = max(6, round(umfang / ziegel_laenge));
    winkel_schritt = 360 / spalten;
    basis_d_unten = d_unten - 2 * relief_tiefe;
    basis_d_oben = d_oben - 2 * relief_tiefe;

    union() {
        cylinder(h = hoehe, d1 = basis_d_unten, d2 = basis_d_oben);
        for (row = [0 : reihen - 1]) {
            versatz = (row % 2 == 0) ? 0 : winkel_schritt / 2;
            z_mitte = row * reihen_hoehe + reihen_hoehe / 2;
            d_lokal = d_unten + (d_oben - d_unten) * (z_mitte / hoehe);
            for (col = [0 : spalten - 1]) {
                winkel = col * winkel_schritt + versatz;
                rotate([0, 0, winkel])
                    translate([0, 0, z_mitte])
                    ziegel_stein(d_lokal, winkel_schritt, reihen_hoehe - fugen_breite, relief_tiefe * 2);
            }
        }
    }
}

// Werkzeug für die Innenbohrung: konischer Kern passend zur Außenverjüngung,
// mit geraden Enden, damit sauber durch beide Stirnflächen geschnitten wird.
module bohrung(hoehe, d_unten, d_oben) {
    union() {
        cylinder(h = hoehe, d1 = d_unten, d2 = d_oben);
        translate([0, 0, -0.5])
            cylinder(h = 0.51, d = d_unten);
        translate([0, 0, hoehe - 0.01])
            cylinder(h = 0.51, d = d_oben);
    }
}

// ============================================================
// Ein Schornstein-Segment: hohler Kegelstumpf mit Ziegeloptik außen,
// glatte durchgehende Bohrung innen. d_unten/d_oben = Außendurchmesser
// am unteren/oberen Ende dieses Segments (Verjüngung nach oben).
// ============================================================
module segment(hoehe, d_unten, d_oben) {
    innen_unten = d_unten - 2 * wandstaerke;
    innen_oben = d_oben - 2 * wandstaerke;
    difference() {
        ziegeloptik(hoehe, d_unten, d_oben);
        bohrung(hoehe, innen_unten, innen_oben);
    }
}

// ============================================================
// Trennring: sichtbarer glatter Bund zwischen zwei Segmenten, mit
// Steckzapfen nach oben und unten, die in die Innenbohrung der
// angrenzenden Segmente greifen und so die Ausrichtung sichern.
// d_unten/d_oben = Außendurchmesser des Schornsteins an der Stelle,
// an der der Ring sitzt (unteres/oberes Ende des Rings).
// ============================================================
module trennring(d_unten, d_oben) {
    ring_d_unten = d_unten + ring_ueberstand;
    ring_d_oben = d_oben + ring_ueberstand;
    innen_unten = d_unten - 2 * wandstaerke;
    innen_oben = d_oben - 2 * wandstaerke;
    zapfen_d_unten = innen_unten - spiel;
    zapfen_d_oben = innen_oben - spiel;

    union() {
        difference() {
            cylinder(h = ring_hoehe, d1 = ring_d_unten, d2 = ring_d_oben);
            bohrung(ring_hoehe, innen_unten, innen_oben);
        }
        // unterer Steckzapfen (greift ins Segment darunter)
        translate([0, 0, -zapfen_hoehe])
            cylinder(h = zapfen_hoehe + 0.01, d = zapfen_d_unten);
        // oberer Steckzapfen (greift ins Segment darüber)
        translate([0, 0, ring_hoehe - 0.01])
            cylinder(h = zapfen_hoehe + 0.01, d = zapfen_d_oben);
    }
}

// ============================================================
// Layout für den Druck: Segmente und Trennringe stehend, nebeneinander
// auf der Druckplatte verteilt. Keine Überhänge, kein Stützmaterial nötig.
// ============================================================
module layout_fuer_druck() {
    max_d = max(aussen_durchmesser, ring_aussen_durchmesser_max);

    for (i = [0 : anzahl_segmente - 1]) {
        z_start = segment_z_start(i);
        d_unten = aussen_d_bei(z_start);
        d_oben = aussen_d_bei(z_start + segment_h(i));
        translate([i * (max_d + plate_abstand), 0, 0])
            segment(segment_h(i), d_unten, d_oben);
    }

    for (i = [0 : anzahl_segmente - 2]) {
        z_start = segment_z_start(i) + segment_h(i);
        d_unten = aussen_d_bei(z_start);
        d_oben = aussen_d_bei(z_start + ring_hoehe);
        translate([i * (max_d + plate_abstand), max_d + plate_abstand, 0])
            trennring(d_unten, d_oben);
    }
}

// ============================================================
// Zusammengesteckte Vorschau (nur zur optischen Kontrolle,
// so würde der fertige Schornstein aussehen)
// ============================================================
module assembliert() {
    for (i = [0 : anzahl_segmente - 1]) {
        z_start = segment_z_start(i);
        d_unten = aussen_d_bei(z_start);
        d_oben = aussen_d_bei(z_start + segment_h(i));
        translate([0, 0, z_start])
            segment(segment_h(i), d_unten, d_oben);
        if (i < anzahl_segmente - 1) {
            ring_d_unten = d_oben;
            ring_d_oben = aussen_d_bei(z_start + segment_h(i) + ring_hoehe);
            translate([0, 0, z_start + segment_h(i)])
                trennring(ring_d_unten, ring_d_oben);
        }
    }
}

// ============================================================
// Hauptausgabe
// ============================================================
if (ansicht == "layout") {
    layout_fuer_druck();
} else {
    assembliert();
}
