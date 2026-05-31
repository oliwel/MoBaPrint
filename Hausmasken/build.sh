#!/bin/bash
# Erzeugt house_data.scad aus CSV und öffnet OpenSCAD zur Vorschau.
# Aufruf: ./build.sh [datei.csv]
set -e
cd "$(dirname "$0")"
python3 parse_house.py "${1:-sample.csv}" > house_data.scad
echo "house_data.scad erzeugt."
openscad house_mask.scad
