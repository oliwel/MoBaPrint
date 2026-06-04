#!/usr/bin/env python3
"""Webanwendung auf Port 8080: CSV eingeben → STL Vorschau / Download."""

import html as h
import os
import shutil
import subprocess
import tempfile
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import parse_qs

BASE_DIR  = os.path.dirname(os.path.abspath(__file__))
PARSE_PY  = os.path.join(BASE_DIR, "parse_house.py")
MASK_SCAD = os.path.join(BASE_DIR, "house_mask.scad")


def _load_template():
    with open(os.path.join(BASE_DIR, "index.html"), encoding="utf-8") as f:
        return f.read()


def _render(csv: str = "") -> str:
    return _load_template().replace("{{csv}}", csv)


class Handler(BaseHTTPRequestHandler):
    def log_message(self, fmt, *args):
        print(fmt % args)

    def _send(self, status, content_type, body):
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body if isinstance(body, bytes) else body.encode())

    def do_GET(self):
        self._send(200, "text/html; charset=utf-8", _render())

    def _read_csv(self):
        length = int(self.headers.get("Content-Length", 0))
        body = self.rfile.read(length).decode("utf-8", errors="replace")
        return parse_qs(body).get("csv", [""])[0]

    def _generate_stl(self, csv_content):
        """Returns (stl_bytes, None) on success, (None, error_str) on failure."""
        tmpdir = tempfile.mkdtemp(prefix="hausmaske_")
        try:
            csv_path  = os.path.join(tmpdir, "input.csv")
            data_scad = os.path.join(tmpdir, "house_data.scad")
            mask_scad = os.path.join(tmpdir, "house_mask.scad")
            stl_path  = os.path.join(tmpdir, "house_mask.stl")

            with open(csv_path, "w", encoding="utf-8") as f:
                f.write(csv_content)

            r1 = subprocess.run(["python3", PARSE_PY, csv_path],
                                 capture_output=True, text=True)
            if r1.returncode != 0:
                return None, "parse_house.py Fehler:\n" + r1.stderr

            with open(data_scad, "w", encoding="utf-8") as f:
                f.write(r1.stdout)

            shutil.copy(MASK_SCAD, mask_scad)

            r2 = subprocess.run(["openscad", "-o", stl_path, mask_scad],
                                 capture_output=True, text=True, cwd=tmpdir)
            if r2.returncode != 0 or not os.path.exists(stl_path):
                return None, "OpenSCAD Fehler:\n" + r2.stderr

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
                page = _render(csv=h.escape(csv_content)).replace("{{error}}", block)
                self._send(422, "text/html; charset=utf-8", page)
            else:
                self.send_response(200)
                self.send_header("Content-Type", "application/octet-stream")
                self.send_header("Content-Disposition", 'attachment; filename="house_mask.stl"')
                self.send_header("Content-Length", str(len(stl_data)))
                self.end_headers()
                self.wfile.write(stl_data)


if __name__ == "__main__":
    addr = ("", 8080)
    httpd = HTTPServer(addr, Handler)
    print("Hausmasken-Generator läuft auf http://localhost:8080")
    httpd.serve_forever()
