# Board Visual Pass v0.1

Goal: make the 5x5 board read as a game scene instead of a debug grid without changing puzzle information.

## Visual language

- Player: small blindfolded figure, no `P` label.
- Candidate: gold melon-like marker, no `?` label.
- Planned route: ocean-blue footprints.
- Traversed route: muted footprints.
- Stick: bamboo line shown from Stage 5 onward only after direction + side are selected.
- Revealed watermelon: green striped melon, shown only after successful SMASH.
- Cell surfaces: warm sand with soft blue/green state shifts instead of saturated debug fills.

## Information boundary

The visual layer must never receive or render the hidden watermelon position during normal play. `watermelon_position` is read only while phase is `clear`, solely to reveal the solved location.

## Architecture

- `board_cell.gd`: procedural per-cell drawing.
- `board_visuals.gd`: public-state synchronization and cell-surface styling.
- `main.gd`: puzzle rules remain unchanged.

This keeps visual iteration isolated from solver behavior and reduces the risk of UI polish introducing puzzle-rule regressions.
