#!/usr/bin/env bash
# build-quiz.sh — build the audio for the "Which one is a fish?" quiz.
#
# Usage: build-quiz.sh <scan.pdf> <output-dir>
#
# Q/A pairs below must stay in sync with the PAIRS array in quiz/index.html
# (same order; PAIRS also maps each pair to its two page images). Questions are
# read by a child voice, answers by a warm adult voice.
set -euo pipefail

PDF=${1:?usage: build-quiz.sh <scan.pdf> <output-dir>}
OUT=${2:?usage: build-quiz.sh <scan.pdf> <output-dir>}
HERE=$(dirname "$(readlink -f "$0")")
Q_VOICE=${Q_VOICE:-en-US-AnaNeural}   # child voice
A_VOICE=${A_VOICE:-en-US-AvaNeural}   # adult voice

QUESTIONS=(
  "Which one is a fish? The sea bream... or the octopus?"
  "Which one is a fish? The crab... or the anemone fish?"
  "Which one is a fish? The sweetfish... or the jellyfish?"
  "Which one is a fish? The starfish... or the sea horse?"
  "Which one is a fish? The shark... or the whale?"
)
ANSWERS=(
  "The sea bream is a fish — it has fins and shiny scales! The octopus is not a fish, it just has eight wiggly arms."
  "The anemone fish is a fish — it swims with little fins! The crab is not a fish, it walks on the sea floor with ten legs."
  "The sweetfish is a fish — it swims in clean rivers with its little fins! The jellyfish is not a fish at all, it is soft and wobbly like jelly."
  "Surprise! The sea horse is a fish — it has tiny fins and gills! The starfish is not a fish, it is a star-shaped animal that creeps along the bottom."
  "Tricky one! The shark is a fish, but the whale is not — the whale is a huge mammal that swims up to the top of the sea to breathe air, just like you!"
)
FINALE="Hooray! You found all the fish! Great job, little explorer!"

mkdir -p "$OUT/img" "$OUT/audio"
pdftoppm -jpeg -r 200 -jpegopt quality=85 "$PDF" "$OUT/img/page"

for i in "${!QUESTIONS[@]}"; do
  n=$((i + 1))
  "$HERE/tts.sh" "${QUESTIONS[$i]}" "$OUT/audio/q$n.mp3" "$Q_VOICE"
  "$HERE/tts.sh" "${ANSWERS[$i]}" "$OUT/audio/a$n.mp3" "$A_VOICE"
  echo "pair $n done"
done
"$HERE/tts.sh" "$FINALE" "$OUT/audio/end.mp3" "$Q_VOICE"

cp "$HERE/../quiz/index.html" "$OUT/"
echo "Done: open $OUT/index.html in a browser."
