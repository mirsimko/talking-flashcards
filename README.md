# Talking Flashcards

Turn a scanned deck of picture flashcards (a PDF, one card per page) into three
self-contained, offline HTML apps with spoken audio:

1. **Slideshow** (`slideshow/`) — one card per slide; the card's English name is
   read aloud on every slide turn.
2. **"Which one is a fish?" quiz** (`quiz/`) — a colorful game for small
   children (ages 2–5). Two cards appear side by side and a child's voice asks
   *"Which one is a fish?"* and names both. Tap anywhere to reveal: the fish
   gets a green ring and a ✅🐟 badge, the other card grays out with a ❌, and a
   warm adult voice explains the answer in one sentence.

3. **"Fish Facts" 3-choice quiz** (`quiz2/`) — four spoken multiple-choice
   questions (where are the gills? what does a fish breathe with? which is not
   a fish? which is the biggest fish?) with three picture cards each. Tap a
   card → cheerful pop-up with the explanation; right/wrong tally at the end.
   Question 1 highlights body parts on the same fish picture with a pulsing
   ring, so no extra artwork is needed for "behind the head / belly / tail".

Everything runs from `file://` with no server, no build step, and no runtime
dependencies — just a folder of JPEGs, a folder of MP3s, and one `index.html`.
Both apps bundle the [Baloo 2](https://fonts.google.com/specimen/Baloo+2)
typeface (SIL OFL, `fonts/`) as a self-hosted woff2, so they look the same on
desktop, Android, and iOS.

Born from a deck of Japanese kids' sea-creature flashcards (海の生物): the deck
was scanned with a phone into a single PDF, and these scripts did the rest.

## How it works

```
scan.pdf ──pdftoppm──▶ img/page-NN.jpg      (200 dpi JPEGs, one per card)
names[]  ──edge-tts──▶ audio/slide-NN.mp3   (one neural-TTS clip per card)
                       index.html           (plain JS slideshow / quiz)
```

Text-to-speech uses Microsoft's free Edge neural voices — either through the
[`edge-tts`](https://pypi.org/project/edge-tts/) CLI, or through a
`transcript-to-podcast` project if you have one (set `T2P_PROJECT` to its
checkout and it will be used via `uv run`). Voices used here:
`en-US-AvaNeural` (narrator/answers) and `en-US-AnaNeural` (child voice for the
quiz questions).

## Requirements

Two command-line tools, plus any modern browser to play the result:

- `pdftoppm` (part of Poppler) — renders the PDF pages to JPEGs
- `edge-tts` — generates the speech (needs network access while building;
  the built apps then work fully offline)

### macOS

Starting from a clean Mac (no Python or pip needed beforehand):

```bash
# 1. Install Homebrew if you don't have it yet (from https://brew.sh)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Poppler (for pdftoppm) and Python (which brings pip with it)
brew install poppler python

# 3. The TTS engine
pip3 install edge-tts
```

If `pip3 install` complains about an "externally managed environment", use
pipx instead — it puts CLI tools in isolated environments and on your PATH:

```bash
brew install pipx && pipx install edge-tts && pipx ensurepath
```

The build scripts use plain Bash and work with the stock macOS shell.

### Linux

```bash
# Debian/Ubuntu
sudo apt install poppler-utils pipx && pipx install edge-tts

# Fedora
sudo dnf install poppler-utils pipx && pipx install edge-tts
```

On either platform, check the install with `pdftoppm -v` and
`edge-tts --list-voices | head`.

## Quick start

```bash
# 1. Slideshow — edit NAMES in scripts/build-slideshow.sh AND in
#    slideshow/index.html to match your PDF's page order, then:
scripts/build-slideshow.sh my-scan.pdf out/slideshow

# 2. Quiz — edit QUESTIONS/ANSWERS in scripts/build-quiz.sh AND the PAIRS
#    array in quiz/index.html (pairs pages + on-screen text), then:
scripts/build-quiz.sh my-scan.pdf out/quiz

# 3. Fish Facts quiz — no PDF; generates the audio and copies the page, then
#    drop your ten option pictures into out/quiz2/img (names in quiz2/index.html):
scripts/build-quiz2.sh out/quiz2

# 4. Open out/<app>/index.html in a browser.
```

Both apps start behind a big **Play** button — browsers block audio until the
first user gesture, so the button doubles as the autoplay unlock.

## Controls

| Action | Slideshow | Quizzes |
|--------|-----------|---------|
| Answer | — | tap a card (Fish Facts: also `A`/`B`/`C` or `1`/`2`/`3`) |
| Advance | click, `→`, `Space`, `PageDown` | tap anywhere after the reveal, `→`, `Space` |
| Go back | `←`, `PageUp` | `←` |
| Replay audio | `R` | `R` |

The quizzes alternate question → reveal for each item and end in a "🎉" screen
with the right/wrong count; tapping it restarts the game.

## Customizing

- **Different deck**: replace the name/question/answer arrays in the two build
  scripts and the matching arrays at the top of each `index.html`
  (`NAMES` in the slideshow, `PAIRS` in the quiz — page filenames, which side
  is correct, and the on-screen captions).
- **Different voices**: `VOICE=en-GB-SoniaNeural scripts/build-slideshow.sh …`
  (also `Q_VOICE`/`A_VOICE` for the quiz). List voices with
  `edge-tts --list-voices`.
- **Different questions** (Fish Facts): edit the `QUESTIONS` array in
  `quiz2/index.html` (prompt, three options with image + label, index of the
  right answer, explanation) and the matching `QUESTIONS`/`ANSWERS` in
  `scripts/build-quiz2.sh`. Option pictures can be anything — the ones used
  for the live demo were generated with ChatGPT from short "flat cartoon
  sticker, white background" prompts, then cropped with ImageMagick.
- **Different question** (Which one is a fish?): nothing about the quiz is fish-specific — change the
  title in `quiz/index.html` and the texts, and it becomes "Which one flies?",
  "Which one is a vegetable?", etc.

## What's not in this repo

The scanned card images and generated MP3s are build outputs (and the card
artwork is not mine to redistribute), so `.gitignore` excludes PDFs, images,
and audio. Bring your own deck.

## License

MIT — see [LICENSE](LICENSE). Covers the code only, not any card artwork you
feed it.
