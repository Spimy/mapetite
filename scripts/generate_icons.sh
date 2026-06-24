#!/usr/bin/env bash
set -euo pipefail

# Run from the repo root (mapetite/)
SVG="mobile-client/assets/logos/logo_icon.svg"
RSVG="/opt/homebrew/bin/rsvg-convert"

# helper: render SVG to opaque white-background PNG
render() {
  local size=$1 dest=$2
  "$RSVG" --background-color="#FFFFFF" --width "$size" --height "$size" \
    "$SVG" -o "$dest"
}

# iOS -------------------------------------------------------------------------
IOS="mobile-client/ios/Runner/Assets.xcassets/AppIcon.appiconset"
render  20  "$IOS/Icon-App-20x20@1x.png"
render  40  "$IOS/Icon-App-20x20@2x.png"
render  60  "$IOS/Icon-App-20x20@3x.png"
render  29  "$IOS/Icon-App-29x29@1x.png"
render  58  "$IOS/Icon-App-29x29@2x.png"
render  87  "$IOS/Icon-App-29x29@3x.png"
render  40  "$IOS/Icon-App-40x40@1x.png"
render  80  "$IOS/Icon-App-40x40@2x.png"
render 120  "$IOS/Icon-App-40x40@3x.png"
render 120  "$IOS/Icon-App-60x60@2x.png"
render 180  "$IOS/Icon-App-60x60@3x.png"
render  76  "$IOS/Icon-App-76x76@1x.png"
render 152  "$IOS/Icon-App-76x76@2x.png"
render 167  "$IOS/Icon-App-83.5x83.5@2x.png"
render 1024 "$IOS/Icon-App-1024x1024@1x.png"
echo "iOS icons generated"

# Android ---------------------------------------------------------------------
ANDROID="mobile-client/android/app/src/main/res"
render  48  "$ANDROID/mipmap-mdpi/ic_launcher.png"
render  72  "$ANDROID/mipmap-hdpi/ic_launcher.png"
render  96  "$ANDROID/mipmap-xhdpi/ic_launcher.png"
render 144  "$ANDROID/mipmap-xxhdpi/ic_launcher.png"
render 192  "$ANDROID/mipmap-xxxhdpi/ic_launcher.png"
echo "Android icons generated"

# Web favicon (transparent — no background) -----------------------------------
"$RSVG" --width 32 --height 32 "$SVG" -o "mobile-client/web/favicon.png"
echo "Web favicon generated"

# Web manifest icons ----------------------------------------------------------
WEB_ICONS="mobile-client/web/icons"
render 192 "$WEB_ICONS/Icon-192.png"
render 512 "$WEB_ICONS/Icon-512.png"

# Maskable icons: green background, logo padded to 80% safe zone
python3 - <<'PYEOF'
from PIL import Image
import subprocess

RSVG = "/opt/homebrew/bin/rsvg-convert"
SVG  = "mobile-client/assets/logos/logo_icon.svg"
OUT  = "mobile-client/web/icons"

def make_maskable(target_px, out_file):
    inner = int(target_px * 0.80)
    pad   = (target_px - inner) // 2
    tmp   = f"/tmp/maskable_inner_{target_px}.png"
    subprocess.run([RSVG, "--background-color=#065F46",
                    "--width", str(inner), "--height", str(inner),
                    SVG, "-o", tmp], check=True)
    base = Image.new("RGBA", (target_px, target_px), (6, 95, 70, 255))
    mark = Image.open(tmp).convert("RGBA")
    base.paste(mark, (pad, pad), mark)
    base.save(out_file, "PNG")

make_maskable(192, f"{OUT}/Icon-maskable-192.png")
make_maskable(512, f"{OUT}/Icon-maskable-512.png")
PYEOF
echo "Web maskable icons generated"

echo ""
echo "All platform icons generated successfully."
