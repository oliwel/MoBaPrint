#!/usr/bin/env python3
"""
Hausmasken-Generator — Webserver + CSV-Parser + Validierung in einer Datei.

CSV-Format:
  # Kommentar (wird verworfen)
  raum
  breite,tiefe,hoehe              (genau 3 Werte, genau 1 Zeile)
  vorne|hinten|links|rechts
  x,y,breite,hoehe                (Fenster/Tür – 4 Werte)
  pos                             (Innenwand-Ansatz – 1 Wert)
  licht
  dx,dy[,rotation]               (2 oder 3 Werte, genau 1 Zeile)
  dach
  x,y,breite,tiefe               (4 Werte)

Standalone: python3 server.py --parse sample.csv > house_data.scad
Server:     python3 server.py
"""

import csv as csv_module
import html as h
import io
import os
import shutil
import subprocess
import sys
import tempfile
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import parse_qs

BASE_DIR  = os.path.dirname(os.path.abspath(__file__))
MASK_SCAD = os.path.join(BASE_DIR, "house_mask.scad")

KNOWN_SECTIONS = {"raum", "vorne", "hinten", "links", "rechts", "licht", "dach"}

# counts: erlaubte Anzahl Werte pro Datenzeile; max_rows: max. Datenzeilen im Abschnitt
_RULES = {
    "raum":   {"counts": {3},    "max_rows": 1, "hint": "breite,tiefe,hoehe"},
    "licht":  {"counts": {2, 3}, "max_rows": 1, "hint": "dx,dy[,rotation]"},
    "vorne":  {"counts": {1, 4}, "hint": "x,y,breite,hoehe  oder  pos"},
    "hinten": {"counts": {1, 4}, "hint": "x,y,breite,hoehe  oder  pos"},
    "links":  {"counts": {1, 4}, "hint": "x,y,breite,hoehe  oder  pos"},
    "rechts": {"counts": {1, 4}, "hint": "x,y,breite,hoehe  oder  pos"},
    "dach":   {"counts": {4},    "hint": "x,y,breite,tiefe"},
}


# ── Validation & Parsing ──────────────────────────────────────────────────────

class ValidationError(Exception):
    pass


def _numeric(s: str) -> bool:
    try:
        float(s)
        return True
    except ValueError:
        return False


def _parse_values(row: list[str]) -> list:
    return [float(v) if "." in v else int(v) for v in row if v]


def validate_and_parse(text: str) -> dict:
    """Validiert den CSV-Text zeilenweise und gibt ein Sections-Dict zurück.

    Schlägt fehl mit ValidationError und einer detaillierten Fehlerliste.
    """
    errors = []
    sections: dict = {}
    current: str | None = None
    row_counts: dict[str, int] = {}

    for lineno, row in enumerate(csv_module.reader(io.StringIO(text)), start=1):
        row = [c.strip() for c in row]

        # Leerzeilen überspringen
        if not row or not any(row):
            continue

        first = row[0]

        # Kommentarzeilen verwerfen
        if first.startswith("#"):
            continue

        # Schlüsselwort-Erkennung: erster Wert ist nicht-numerisch und nicht leer
        if first and not _numeric(first):
            keyword = first.lower()
            if keyword not in KNOWN_SECTIONS:
                errors.append(
                    f'Zeile {lineno}: Unbekanntes Schlüsselwort "{first}" - '
                    f"erlaubt: {', '.join(sorted(KNOWN_SECTIONS))}"
                )
            else:
                current = keyword
                sections.setdefault(current, [])
                row_counts.setdefault(current, 0)
            continue

        # Datenzeile
        if current is None:
            errors.append(f"Zeile {lineno}: Datenwerte vor dem ersten Abschnitts-Schlüsselwort")
            continue

        values = [c for c in row if c]

        # Alle Werte müssen numerisch sein
        bad = [v for v in values if not _numeric(v)]
        if bad:
            errors.append(f"Zeile {lineno}: Nicht-numerische Werte: {', '.join(bad)}")
            continue

        rule = _RULES.get(current, {})
        count = len(values)

        # Anzahl der Werte prüfen
        allowed_counts = rule.get("counts")
        if allowed_counts and count not in allowed_counts:
            allowed_str = " oder ".join(str(n) for n in sorted(allowed_counts))
            errors.append(
                f'Zeile {lineno}: Abschnitt "{current}" erwartet {allowed_str} Wert(e) '
                f"({rule['hint']}), gefunden: {count}"
            )
            continue

        # Maximale Zeilenanzahl prüfen
        max_rows = rule.get("max_rows")
        row_counts[current] += 1
        if max_rows and row_counts[current] > max_rows:
            errors.append(
                f'Zeile {lineno}: Abschnitt "{current}" erlaubt maximal '
                f"{max_rows} Datenzeile(n)"
            )
            continue

        sections[current].append(_parse_values(values))

    if errors:
        raise ValidationError("\n".join(errors))

    return sections


# ── SCAD-Generierung ──────────────────────────────────────────────────────────

def _vec(windows: list) -> str:
    entries = ", ".join(f"[{','.join(str(v) for v in w)}]" for w in windows)
    return f"[{entries}]"


def _list1d(values: list) -> str:
    return "[" + ", ".join(str(v) for v in values) + "]"


def _split_wall(entries: list) -> tuple[list, list]:
    wins = [e for e in entries if len(e) == 4]
    pos  = [e[0] for e in entries if len(e) == 1]
    return wins, pos


def generate_scad(sections: dict) -> str:
    w, d, room_h = sections.get("raum", [[100, 80, 30]])[0]

    licht_rows = sections.get("licht", [])
    licht_row  = licht_rows[0] if licht_rows else [0, 0]
    dx, dy     = licht_row[0], licht_row[1]
    licht_rot  = licht_row[2] if len(licht_row) >= 3 else 0

    front_wins, front_pos = _split_wall(sections.get("vorne",  []))
    back_wins,  back_pos  = _split_wall(sections.get("hinten", []))
    left_wins,  left_pos  = _split_wall(sections.get("links",  []))
    right_wins, right_pos = _split_wall(sections.get("rechts", []))

    lines = [
        f"room_width  = {w};",
        f"room_depth  = {d};",
        f"room_height = {room_h};",
        f"front_windows  = {_vec(front_wins)};",
        f"back_windows   = {_vec(back_wins)};",
        f"left_windows   = {_vec(left_wins)};",
        f"right_windows  = {_vec(right_wins)};",
        f"has_licht      = {'true' if 'licht' in sections else 'false'};",
        f"licht_offset   = [{dx}, {dy}];",
        f"licht_rotation = {licht_rot};",
        f"dach           = {_vec(sections.get('dach', []))};",
        f"front_wall_pos = {_list1d(front_pos)};",
        f"back_wall_pos  = {_list1d(back_pos)};",
        f"left_wall_pos  = {_list1d(left_pos)};",
        f"right_wall_pos = {_list1d(right_pos)};",
    ]
    return "\n".join(lines)


def csv_to_scad(text: str) -> str:
    """Validiert CSV und gibt SCAD-Inhalt zurück. Wirft ValidationError bei Fehlern."""
    return generate_scad(validate_and_parse(text))


# ── HTTP-Server ───────────────────────────────────────────────────────────────

def _load_template() -> str:
    with open(os.path.join(BASE_DIR, "index.html"), encoding="utf-8") as f:
        return f.read()


def _render(csv_text: str = "") -> str:
    return _load_template().replace("{{csv}}", csv_text)


class Handler(BaseHTTPRequestHandler):
    def log_message(self, fmt, *args):
        print(fmt % args)

    def _send(self, status: int, content_type: str, body):
        data = body if isinstance(body, bytes) else body.encode()
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def do_GET(self):
        self._send(200, "text/html; charset=utf-8", _render())

    def _read_csv(self) -> str:
        length = int(self.headers.get("Content-Length", 0))
        body = self.rfile.read(length).decode("utf-8", errors="replace")
        return parse_qs(body).get("csv", [""])[0]

    def _generate_stl(self, csv_content: str) -> tuple:
        """Gibt (stl_bytes, None) bei Erfolg oder (None, fehler_str) zurück."""
        try:
            scad_data = csv_to_scad(csv_content)
        except ValidationError as e:
            return None, str(e)

        tmpdir = tempfile.mkdtemp(prefix="hausmaske_")
        try:
            data_scad = os.path.join(tmpdir, "house_data.scad")
            mask_scad = os.path.join(tmpdir, "house_mask.scad")
            stl_path  = os.path.join(tmpdir, "house_mask.stl")

            with open(data_scad, "w", encoding="utf-8") as f:
                f.write(scad_data)
            shutil.copy(MASK_SCAD, mask_scad)

            r = subprocess.run(
                ["openscad", "-o", stl_path, mask_scad],
                capture_output=True, text=True, cwd=tmpdir,
            )
            if r.returncode != 0 or not os.path.exists(stl_path):
                return None, "OpenSCAD Fehler:\n" + r.stderr

            with open(stl_path, "rb") as f:
                return f.read(), None
        finally:
            shutil.rmtree(tmpdir, ignore_errors=True)

    def do_POST(self):
        csv_content = self._read_csv()
        stl_data, error = self._generate_stl(csv_content)

        if self.path == "/preview":
            if error:
                self._send(422, "text/plain; charset=utf-8", error)
            else:
                self._send(200, "model/stl", stl_data)
        else:
            if error:
                block = f'<div class="error">{h.escape(error)}</div>'
                page = _render(h.escape(csv_content)).replace("{{error}}", block)
                self._send(422, "text/html; charset=utf-8", page)
            else:
                self.send_response(200)
                self.send_header("Content-Type", "application/octet-stream")
                self.send_header("Content-Disposition", 'attachment; filename="house_mask.stl"')
                self.send_header("Content-Length", str(len(stl_data)))
                self.end_headers()
                self.wfile.write(stl_data)


# ── Entry point ───────────────────────────────────────────────────────────────

if __name__ == "__main__":
    if len(sys.argv) >= 3 and sys.argv[1] == "--parse":
        with open(sys.argv[2], encoding="utf-8") as f:
            text = f.read()
        try:
            print(csv_to_scad(text))
        except ValidationError as e:
            print(f"Fehler:\n{e}", file=sys.stderr)
            sys.exit(1)
    else:
        addr = ("", 8080)
        httpd = HTTPServer(addr, Handler)
        print("Hausmasken-Generator läuft auf http://localhost:8080")
        httpd.serve_forever()
