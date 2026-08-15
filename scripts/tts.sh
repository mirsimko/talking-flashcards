#!/usr/bin/env bash
# tts.sh — speak one line of text into an MP3.
#
# Usage: tts.sh "text to speak" out.mp3 [voice]
#
# Uses a transcript-to-podcast uv project when T2P_PROJECT points at its
# checkout, otherwise falls back to the plain `edge-tts` CLI
# (pip install edge-tts). Both stream Microsoft's free neural voices, so
# network access is required while building.
set -euo pipefail

TEXT=${1:?usage: tts.sh "text" out.mp3 [voice]}
OUT=${2:?usage: tts.sh "text" out.mp3 [voice]}
VOICE=${3:-en-US-AvaNeural}

if [[ -n "${T2P_PROJECT:-}" ]]; then
  tmp=$(mktemp --suffix=.md)
  printf '**Narrator:** %s\n' "$TEXT" > "$tmp"
  uv run --project "$T2P_PROJECT" transcript-to-podcast "$tmp" \
    -o "$OUT" --voice "Narrator=$VOICE" >/dev/null
  rm -f "$tmp"
else
  edge-tts --voice "$VOICE" --text "$TEXT" --write-media "$OUT"
fi
