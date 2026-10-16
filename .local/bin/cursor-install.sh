#!/bin/sh
# cursor-install.sh — Installe et génère le thème Bibata-Modern-Sky (Catppuccin Sky Cyan, large & trapu)
set -eu

DEST="$HOME/.local/share/icons"
BASE_THEME="Bibata-Modern-Ice"
TARGET_THEME="Bibata-Modern-Sky"
URL="https://github.com/ful1e5/Bibata_Cursor/releases/download/v2.0.7/${BASE_THEME}.tar.xz"

mkdir -p "$DEST" "$HOME/.icons"
echo "=== Installation du thème de base $BASE_THEME ==="
curl -sSL "$URL" -o "/tmp/${BASE_THEME}.tar.xz"

echo "Extraction dans $DEST/..."
tar -xf "/tmp/${BASE_THEME}.tar.xz" -C "$DEST/"
rm -f "/tmp/${BASE_THEME}.tar.xz"
ln -sfn "$DEST/$BASE_THEME" "$HOME/.icons/$BASE_THEME"

echo "=== Génération du thème personnalisé $TARGET_THEME (Catppuccin Sky) ==="
python3 - << 'EOF'
import os
import shutil
import struct

SRC_DIR = os.path.expanduser("~/.local/share/icons/Bibata-Modern-Ice")
DST_DIR = os.path.expanduser("~/.local/share/icons/Bibata-Modern-Sky")

if os.path.exists(DST_DIR):
    shutil.rmtree(DST_DIR)

shutil.copytree(SRC_DIR, DST_DIR, symlinks=True)

index_theme = os.path.join(DST_DIR, "index.theme")
with open(index_theme, "w") as f:
    f.write("[Icon Theme]\nName=Bibata-Modern-Sky\nComment=Bibata Modern in Catppuccin Sky\nInherits=Bibata-Modern-Ice\n")

cursor_theme = os.path.join(DST_DIR, "cursor.theme")
with open(cursor_theme, "w") as f:
    f.write("[Icon Theme]\nInherits=Bibata-Modern-Sky\n")

cursors_dir = os.path.join(DST_DIR, "cursors")
SKY_R = 137.0 / 255.0
SKY_G = 220.0 / 255.0
SKY_B = 235.0 / 255.0

processed = 0
for fname in os.listdir(cursors_dir):
    fpath = os.path.join(cursors_dir, fname)
    if os.path.islink(fpath) or not os.path.isfile(fpath):
        continue

    with open(fpath, "rb") as f:
        data = bytearray(f.read())

    if len(data) < 16 or data[:4] != b'Xcur':
        continue

    magic, header, version, ntoc = struct.unpack("4sIII", data[:16])
    for i in range(ntoc):
        type_, subtype, pos = struct.unpack("III", data[16+i*12:28+i*12])
        if pos + 36 > len(data):
            continue
        ch_header, ch_type, ch_subtype, ch_version, width, height, xhot, yhot, delay = struct.unpack("IIIIIIIII", data[pos:pos+36])
        pixel_start = pos + 36
        pixel_count = width * height
        pixel_bytes = pixel_count * 4
        if pixel_start + pixel_bytes > len(data):
            continue

        for p in range(pixel_start, pixel_start + pixel_bytes, 4):
            b = data[p]
            g = data[p+1]
            r = data[p+2]
            a = data[p+3]
            if a > 0:
                data[p]   = int(round(b * SKY_B))
                data[p+1] = int(round(g * SKY_G))
                data[p+2] = int(round(r * SKY_R))

    with open(fpath, "wb") as f:
        f.write(data)
    processed += 1

print(f"Génération terminée : {processed} curseurs traités dans {DST_DIR}")
EOF

ln -sfn "$DEST/$TARGET_THEME" "$HOME/.icons/$TARGET_THEME"
echo "=== Curseur $TARGET_THEME généré et installé avec succès ! ==="
