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
        int(s)
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
                    values = [int(c.strip()) for c in row if c.strip()]
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
    dx, dy = licht_rows[0] if licht_rows else [0, 0]

    front_wins, front_pos = split(sections.get("vorne",  []))
    back_wins,  back_pos  = split(sections.get("hinten", []))
    left_wins,  left_pos  = split(sections.get("links",  []))
    right_wins, right_pos = split(sections.get("rechts", []))

    lines = [
        f"room_width  = {w};",
        f"room_depth  = {d};",
        f"room_height = {h};",
        f"front_windows  = {vec(front_wins)};",
        f"back_windows   = {vec(back_wins)};",
        f"left_windows   = {vec(left_wins)};",
        f"right_windows  = {vec(right_wins)};",
        f"licht_offset   = [{dx}, {dy}];",
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
