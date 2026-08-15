#!/usr/bin/env bash
# build-slideshow.sh — turn a scanned flashcard PDF into a talking slideshow.
#
# Usage: build-slideshow.sh <scan.pdf> <output-dir>
#
# Edit NAMES to match the PDF page order, and keep it in sync with the NAMES
# array in slideshow/index.html. One MP3 is generated per card; the page images
# are rendered with pdftoppm at 200 dpi.
set -euo pipefail

PDF=${1:?usage: build-slideshow.sh <scan.pdf> <output-dir>}
OUT=${2:?usage: build-slideshow.sh <scan.pdf> <output-dir>}
HERE=$(dirname "$(readlink -f "$0")")
VOICE=${VOICE:-en-US-AvaNeural}

# Cards from extra single-page PDFs can be appended: render them separately
# with pdftoppm and rename to the next page-NN.jpg before adding a name here.
NAMES=(
  "Bonito shark" "Anemone fish" "Sea bream" "Zuwai crab" "Octopus"
  "Starfish" "Sea horse" "Jellyfish" "Prawn" "Squid"
  "Abalone" "Umeboshi sea anemone" "Cherry clam" "Turban shell"
  "Sperm whale"
)

mkdir -p "$OUT/img" "$OUT/audio"
pdftoppm -jpeg -r 200 -jpegopt quality=85 "$PDF" "$OUT/img/page"

for i in "${!NAMES[@]}"; do
  n=$(printf "%02d" $((i + 1)))
  "$HERE/tts.sh" "${NAMES[$i]}." "$OUT/audio/slide-$n.mp3" "$VOICE"
  echo "audio/slide-$n.mp3  <- ${NAMES[$i]}"
done

cp "$HERE/../slideshow/index.html" "$OUT/"
echo "Done: open $OUT/index.html in a browser."
