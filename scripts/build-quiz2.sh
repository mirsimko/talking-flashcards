#!/usr/bin/env bash
# build-quiz2.sh — build the audio for the 3-choice "Fish Facts" quiz.
#
# Usage: build-quiz2.sh <output-dir>
#
# Unlike the other two builders this one takes no PDF: the option images are
# standalone files (see quiz2/index.html QUESTIONS → img/*.png) that you drop
# into <output-dir>/img yourself. Questions are read by a child voice (question
# text + the three options), explanations by a warm adult voice.
set -euo pipefail

OUT=${1:?usage: build-quiz2.sh <output-dir>}
HERE=$(cd "$(dirname "$0")" && pwd)
Q_VOICE=${Q_VOICE:-en-US-AnaNeural}   # child voice
A_VOICE=${A_VOICE:-en-US-AvaNeural}   # adult voice

QUESTIONS=(
  "Where are a fish's gills? A: just behind the head. B: on the belly. C: on the tail."
  "What does a fish use to breathe under the water? A: lungs. B: gills. C: fins."
  "Which one is NOT a fish? A: the shark. B: the tuna. C: the dolphin."
  "Which one is the biggest fish? A: the whale shark. B: the whale. C: the bluefin tuna."
)
ANSWERS=(
  "The gills are just behind the head! A fish opens and closes its gill covers to breathe — look closely next time you see one!"
  "Fish breathe with their gills — they pull the air right out of the water! Lungs are for animals that breathe air, like you, and fins are for swimming."
  "The dolphin is not a fish — it is a mammal! It swims up to the top to breathe air, and it feeds its babies milk. Sharks and tuna are fish."
  "The whale shark is the biggest fish in the whole world — as long as a bus! The whale is even bigger, but it is not a fish, it is a mammal. The bluefin tuna is big, but not that big!"
)
FINALE="Hooray! You got them all right! You are a real fish expert!"
CORRECT="Yay! That's right!"
WRONG="Oops! Not that one!"
# score-K.mp3 is played on the end screen for K correct answers (K = all → FINALE)
SCORES=(
  "The fish kept their secrets today! Let's play again and learn them all!"
  "You got one of the four right! Let's play again and learn the rest!"
  "Two out of four! Great job — let's play again for more!"
  "Three out of four! Wow, so close to all of them!"
)

mkdir -p "$OUT/img" "$OUT/audio"
for i in "${!QUESTIONS[@]}"; do
  n=$((i + 1))
  "$HERE/tts.sh" "${QUESTIONS[$i]}" "$OUT/audio/q$n.mp3" "$Q_VOICE"
  "$HERE/tts.sh" "${ANSWERS[$i]}" "$OUT/audio/a$n.mp3" "$A_VOICE"
  echo "question $n done"
done
"$HERE/tts.sh" "$FINALE" "$OUT/audio/end.mp3" "$Q_VOICE"
"$HERE/tts.sh" "$CORRECT" "$OUT/audio/correct.mp3" "$Q_VOICE"
"$HERE/tts.sh" "$WRONG" "$OUT/audio/wrong.mp3" "$Q_VOICE"
for k in "${!SCORES[@]}"; do
  "$HERE/tts.sh" "${SCORES[$k]}" "$OUT/audio/score-$k.mp3" "$Q_VOICE"
done

cp "$HERE/../quiz2/index.html" "$OUT/"
cp -r "$HERE/../quiz2/fonts" "$OUT/"
echo "Done: put the option images in $OUT/img and open $OUT/index.html in a browser."
