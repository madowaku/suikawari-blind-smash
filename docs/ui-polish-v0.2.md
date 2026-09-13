# SUIKAWARI UI Polish v0.2

## Goal

Make the Grant Demo read as a friendly deduction game rather than a debug board, without changing puzzle rules.

## Typography roles

The runtime uses `SystemFont` with fallbacks, so no font files are bundled.

- Heading: `Nunito` 800, then rounded/system sans fallbacks
- Move notation / HUD / observation log: `JetBrains Mono` 700, then `Consolas` / `Courier New`
- Body: `Noto Sans JP` 500, then `Yu Gothic UI` / `Meiryo` / `Arial`

Roles matter more than exact font availability:

- headings should feel friendly and game-like
- move notation should be easy to scan as structured information
- explanatory copy should stay highly readable in Japanese and English

## Visual hierarchy

1. Board remains the dominant object.
2. HUD is compact and dark, carrying stage / PAR / turn / candidate count.
3. Current rule prompt is a quiet paper card.
4. Result feedback is transient but visually strongest after a move.
5. Planning notation is compact and technical.
6. GO is ocean blue. SMASH is watermelon coral.
7. Observation history is a real reasoning surface, not footer text.

## Motion

- Selected direction / step / stick buttons scale to 1.035.
- Existing result pop remains the strongest UI motion.
- Avoid constant ambient motion.

## Palette

- sand background: `#F4E8CF`
- paper surface: `#FFF8E9`
- muted sand: `#EAD9B6`
- ink: `#2B3038`
- ocean blue: `#3B9BC3`
- watermelon coral: `#E85D3F`
- sun yellow: `#F2C14E`

## Guardrails

- UI must never reveal hidden watermelon truth.
- COLDER is information, not failure.
- Stage 10-11 copy must not explain the information-vs-position insight.
- Visual polish should remain isolated from puzzle rules whenever practical.
