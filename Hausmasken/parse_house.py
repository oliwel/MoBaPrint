#!/usr/bin/env python3
"""Liest eine Hausmasken-CSV und gibt eine OpenSCAD-Datendatei auf stdout aus.

CSV-Format:
  raum
  breite,tiefe,hoehe
  vorne|rechts|hinten|links
  x_start,y_start,x_size,y_size   (Fenster/Tür – 4 Werte)
  pos                              (Innenwand-Ansatzpunkt – 1 Wert)
  licht
  dx,dy          (Offset von der Mitte; ohne Zeile: 0,0)
  dach
  x,y,breite,tiefe

Aufruf: python3 parse_house.py sample.csv > house_data.scad
"""

import csv
import sys


def is_numeric(s):
    try:
        float(s)
        return True
    except ValueError:
        return False


def parse(filename):
    sections = {}
    current = None
    with open(filename, newline="") as f:
        for row in csv.reader(f):
            if not row or not any(c.strip() for c in row):
                continue
            first = row[0].strip()
            if first == "" or is_numeric(first):
                if current is not None:
                    values = [float(c.strip()) if '.' in c else int(c.strip()) for c in row if c.strip()]
                    sections[current].append(values)
            else:
                current = first
                sections.setdefault(current, [])
    return sections


def vec(windows):
    entries = ", ".join(f"[{','.join(str(v) for v in w)}]" for w in windows)
    return f"[{entries}]"


def list_1d(values):
    return "[" + ", ".join(str(v) for v in values) + "]"


def split(entries):
    wins = [e for e in entries if len(e) == 4]
    pos  = [e[0] for e in entries if len(e) == 1]
    return wins, pos


def generate(sections):
    w, d, h = sections.get("raum", [[100, 80, 30]])[0]
    licht_rows = sections.get("licht", [])
    licht_row = licht_rows[0] if licht_rows else [0, 0]
    dx, dy = licht_row[0], licht_row[1]
    licht_rot = licht_row[2] if len(licht_row) >= 3 else 0

    front_wins, front_pos = split(sections.get("vorne",  []))
    back_wins,  back_pos  = split(sections.get("hinten", []))
    left_wins,  left_pos  = split(sections.get("links",  []))
    right_wins, right_pos = split(sections.get("rechts", []))

    has_licht = "licht" in sections

    lines = [
        f"room_width  = {w};",
        f"room_depth  = {d};",
        f"room_height = {h};",
        f"front_windows  = {vec(front_wins)};",
        f"back_windows   = {vec(back_wins)};",
        f"left_windows   = {vec(left_wins)};",
        f"right_windows  = {vec(right_wins)};",
        f"has_licht      = {'true' if has_licht else 'false'};",
        f"licht_offset   = [{dx}, {dy}];",
        f"licht_rotation = {licht_rot};",
        f"dach           = {vec(sections.get('dach', []))};",
        f"front_wall_pos = {list_1d(front_pos)};",
        f"back_wall_pos  = {list_1d(back_pos)};",
        f"left_wall_pos  = {list_1d(left_pos)};",
        f"right_wall_pos = {list_1d(right_pos)};",
    ]
    print("\n".join(lines))


if __name__ == "__main__":
    filename = sys.argv[1] if len(sys.argv) > 1 else "sample.csv"
    generate(parse(filename))
