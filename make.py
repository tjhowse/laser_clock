#!/usr/bin/python3

import os
from pathlib import Path
import ezdxf
from ezdxf import colors
from ezdxf.enums import TextEntityAlignment

def insert_text_into_dxf(dxf_path:Path, text:str, x:float, y:float, z:float, height:float, color):
    dxf = ezdxf.readfile(dxf_path)
    msp = dxf.modelspace()
    msp.add_text(text, dxfattribs={
        'height': height,
        'color': color,
        'rotation': 0,
        'style': 'OpenSans-Regular',
        'insert': (x, y, z),
    })
    dxf.saveas(dxf_path)

SCAD_FILE_NAME = "clock.scad"

part_revsion = 0
files = []
grab_mode = False
with open(SCAD_FILE_NAME) as f:
    for line in f:
        if "PARTSMARKERSTART" in line:
            grab_mode = True
            continue
        if "PARTSMARKEREND" in line:
            grab_mode = False
            continue
        if line.strip().startswith("//"):
            continue
        if "part_revision_number" in line:
            part_revsion = int(line.split("=")[1].strip()[:-1])
            continue
        if grab_mode:
            files.append(line.split()[0].removeprefix("export_"))
print("Part revsion:", part_revsion)
for file in files:
    print(f"Processing {file}")
    os.system(f"openscad -o {file}.dxf {SCAD_FILE_NAME} -D z_scale=0 -D xy_scale=1 -D batch_export=true -D export_{file}=true")
    insert_text_into_dxf(Path(file + ".dxf"), f"{part_revsion}", 0, 0, 0, 3, colors.BLUE)