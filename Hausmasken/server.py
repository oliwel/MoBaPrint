#!/usr/bin/env python3
"""
Hausmasken-Generator — Webserver + CSV-Parser + Validierung in einer Datei.

CSV-Format:
  # Kommentar (wird verworfen)
  raum
  breite,tiefe,hoehe              (genau 3 Werte, Zeile 1)
  [offset]                        (opt. Zeile 2: 1|2|4|5 Werte)
    1 Wert  → alle 4 Wände
    2 Werte → X-Wände (vorne/hinten), Y-Wände (rechts/links)
    4 Werte → vorne, rechts, hinten, links
    5. Wert → Fenster-Offset von unten
  vorne|hinten|links|rechts
  x,y,breite,hoehe                (Fenster/Tür – 4 Werte)
  pos                             (Innenwand-Ansatz – 1 Wert)
  licht
  x,y[,rotation]                 (2 oder 3 Werte, mehrere Zeilen möglich)
  x/y = Abstand von links vorne zur unteren linken Ecke des Ausschnitts
  ohne Werte: Ausschnitt wird automatisch zentriert
  dach
  x,y,breite,tiefe               (4 Werte)

Standalone: python3 server.py --parse sample.csv > house_data.scad
Server:     python3 server.py
"""

import csv as csv_module
import html as h
import io
import logging
import math
import os
import shutil
import subprocess
import sys
import tempfile
import threading
import time
from collections import defaultdict
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import parse_qs

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
logger = logging.getLogger(__name__)

MAX_BODY = 4 * 1024  # 4 KB

_rate_lock = threading.Lock()
_rate_data: dict[str, list[float]] = defaultdict(list)
RATE_WINDOW = 60   # Sekunden
RATE_LIMIT   = 10  # POST-Anfragen pro Minute pro IP


def _rate_ok(ip: str) -> bool:
    now = time.time()
    with _rate_lock:
        ts = [t for t in _rate_data[ip] if now - t < RATE_WINDOW]
        if len(ts) >= RATE_LIMIT:
            return False
        ts.append(now)
        _rate_data[ip] = ts
        return True

BASE_DIR  = os.path.dirname(os.path.abspath(__file__))
MASK_SCAD = os.path.join(BASE_DIR, "house_mask.scad")

KNOWN_SECTIONS = {"raum", "vorne", "hinten", "links", "rechts", "licht", "dach"}

# counts: erlaubte Anzahl Werte pro Datenzeile; max_rows: max. Datenzeilen im Abschnitt
_RULES = {
    "raum":   {"max_rows": 2, "hint": "breite,tiefe,hoehe"},
    "licht":  {"counts": {2, 3}, "hint": "x,y[,rotation]"},
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
        return math.isfinite(float(s))
    except ValueError:
        return False


def _parse_values(row: list[str]) -> list:
    result = []
    for v in row:
        if not v:
            continue
        num = float(v) if "." in v else int(v)
        if num < 0 or num > 9999:
            raise ValidationError(f"Wert außerhalb des erlaubten Bereichs (0–9999): {v}")
        result.append(num)
    return result


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
        if current == "raum":
            _row = row_counts.get(current, 0)
            if _row == 0 and count != 3:
                errors.append(
                    f'Zeile {lineno}: "raum" Zeile 1 erwartet 3 Werte (breite,tiefe,hoehe), gefunden: {count}'
                )
                continue
            if _row == 1 and count not in {1, 2, 4, 5}:
                errors.append(
                    f'Zeile {lineno}: "raum" Offset erwartet 1, 2, 4 oder 5 Werte '
                    f"(alle | x,y | vorne,rechts,hinten,links[,unten]), gefunden: {count}"
                )
                continue
        else:
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


def _expand_offset(vals: list) -> list:
    """Expand 1/2/4/5 offset values to [front, right, back, left, bottom]."""
    n = len(vals)
    if n == 1:
        v = vals[0]
        return [v, v, v, v, 0]
    if n == 2:
        x, y = vals
        return [x, y, x, y, 0]  # front+back = X-Wände, right+left = Y-Wände
    if n == 4:
        return list(vals) + [0]
    return list(vals)  # n == 5: front, right, back, left, bottom


def _shift_windows(windows: list, dx, dz) -> list:
    if dx == 0 and dz == 0:
        return windows
    return [[w[0] + dx, w[1] + dz, w[2], w[3]] for w in windows]


def _split_wall(entries: list) -> tuple[list, list]:
    wins = [e for e in entries if len(e) == 4]
    pos  = [e[0] for e in entries if len(e) == 1]
    return wins, pos


def generate_scad(sections: dict) -> str:
    raum_rows = sections.get("raum", [[100, 80, 30]])
    w, d, room_h = raum_rows[0]
    off_f, off_r, off_b, off_l, off_z = (
        _expand_offset(raum_rows[1]) if len(raum_rows) >= 2 else [0, 0, 0, 0, 0]
    )

    licht_rows = sections.get("licht")
    if licht_rows is None:
        licht_val = "[]"
    elif len(licht_rows) == 0:
        # Kein Wert angegeben → numerisch zentrieren (licht_w/licht_d-Defaults aus house_mask.scad)
        cx = (w - 40) / 2
        cy = (d - 35) / 2
        licht_val = f"[[{cx}, {cy}, 0]]"
    else:
        entries = [[row[0], row[1], row[2] if len(row) >= 3 else 0] for row in licht_rows]
        licht_val = _vec(entries)

    front_wins, front_pos = _split_wall(sections.get("vorne",  []))
    back_wins,  back_pos  = _split_wall(sections.get("hinten", []))
    left_wins,  left_pos  = _split_wall(sections.get("links",  []))
    right_wins, right_pos = _split_wall(sections.get("rechts", []))

    front_wins = _shift_windows(front_wins, off_f, off_z)
    back_wins  = _shift_windows(back_wins,  off_b, off_z)
    left_wins  = _shift_windows(left_wins,  off_l, off_z)
    right_wins = _shift_windows(right_wins, off_r, off_z)

    lines = [
        f"room_width  = {w};",
        f"room_depth  = {d};",
        f"room_height = {room_h};",
        f"front_windows  = {_vec(front_wins)};",
        f"back_windows   = {_vec(back_wins)};",
        f"left_windows   = {_vec(left_wins)};",
        f"right_windows  = {_vec(right_wins)};",
        "// licht = [[x, y, rotation], ...]  x/y = Abstand zur unteren linken Ecke",
        f"licht          = {licht_val};",
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

    def _security_headers(self):
        self.send_header("X-Content-Type-Options", "nosniff")
        self.send_header("X-Frame-Options", "DENY")
        self.send_header("Referrer-Policy", "no-referrer")

    def _send(self, status: int, content_type: str, body):
        data = body if isinstance(body, bytes) else body.encode()
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(data)))
        self._security_headers()
        self.end_headers()
        self.wfile.write(data)

    def do_GET(self):
        self._send(200, "text/html; charset=utf-8", _render())

    def _read_csv(self) -> str | None:
        length = int(self.headers.get("Content-Length", 0))
        if length > MAX_BODY:
            self._send(413, "text/plain; charset=utf-8", "Anfrage zu groß (max 4 KB)")
            return None
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

            try:
                r = subprocess.run(
                    ["openscad", "-o", stl_path, mask_scad],
                    capture_output=True, text=True, cwd=tmpdir,
                    timeout=60,
                )
            except subprocess.TimeoutExpired:
                logger.error("OpenSCAD timeout nach 60s")
                return None, "STL-Generierung abgebrochen (Timeout)."
            if r.returncode != 0 or not os.path.exists(stl_path):
                logger.error("OpenSCAD Fehler: %s", r.stderr)
                return None, "STL-Generierung fehlgeschlagen. Bitte Eingabe prüfen."

            with open(stl_path, "rb") as f:
                return f.read(), None
        finally:
            shutil.rmtree(tmpdir, ignore_errors=True)

    def do_POST(self):
        ip = self.client_address[0]
        if not _rate_ok(ip):
            self._send(429, "text/plain; charset=utf-8", "Zu viele Anfragen – bitte warten.")
            return

        csv_content = self._read_csv()
        if csv_content is None:
            return

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
                self._security_headers()
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
