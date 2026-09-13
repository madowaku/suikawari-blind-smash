# SUIKAWARI: BLIND SMASH

A solo deduction puzzle inspired by Japanese suikawari.

## Current prototype

The prototype now contains the complete **12-stage solver-verified v0.4.1 Grant Demo core set** in a data-driven sequence.

- Godot 4.7 project
- 5x5 board
- Player starts at **C5** in all 12 Grant Demo stages
- Hidden watermelon is randomized among each stage's candidate positions
- Choose a direction and **1-4 steps**
- Press **GO** to commit
- Movement resolves one tile at a time at 0.20 seconds per step
- Read **HOTTER / SAME / COLDER** after stopping
- From Stage 5 onward, choose **LEFT / RIGHT** stick side and listen for **KOTSU / K1-K4**
- Each completed move is written to the observation log
- Stand on the candidate you believe is correct and press **SMASH**
- Successful SMASH advances through all 12 stages; Stage 12 ends on **REPLAY**
- Temporary procedural footsteps, temperature tones, KNOCK, and SMASH feedback are included

The true watermelon position is never displayed before a successful smash.

## Locked v0.4.1 Grant Demo stages

| Stage | Candidates | PAR | Stick | Solver-verified best opening |
| --- | --- | ---: | --- | --- |
| 1 | A5 / E5 | 2 | Off | Tutorial ties |
| 2 | A1 / C4 / E5 | 3 | Off | N1 / N2 tie |
| 3 | A1 / A4 / C2 / D5 | 3 | Off | **N2** |
| 4 | A2 / D2 / D3 | 3 | Off | **E1** |
| 5 | A4 / B4 / D3 / E4 | 3 | On | **N1L** |
| 6 | A4 / B3 / D4 / E4 | 3 | On | **N1R** |
| 7 | A4 / B3 / C2 / D5 | 3 | On | **N2L** |
| 8 | A2 / B4 / E2 / E5 | 3 | On | **N3L** |
| 9 | A1 / A2 / B2 / C3 | 3 | On | **N4L** |
| 10 | A3 / B2 / C3 / C4 / D3 | 3 | On | **N2R** |
| 11 | B1 / B3 / C2 / C3 / E1 | 3 | On | **N2L** |
| 12 | A1 / A2 / B1 / C2 / C3 / C4 / D1 / E1 | 4 | On | **N4R** |

Stages 1-4 deliberately hide the stick controls. Stage 5 reveals LEFT / RIGHT as the third committed input. Stages 10-11 are intentionally designed so that maximizing immediate information is not always the optimal strategy; stopping position matters too.

Stage definitions:

`res://src/stage_catalog.gd`

Reusable data model:

`res://src/stage_data.gd`

Grant Demo runtime guard:

`res://src/grant_demo.gd`

The runtime asserts that exactly 12 stages load, IDs are sequential, all starts are C5, stick unlock happens at Stage 5, and the final stage keeps PAR 4.

## Stick orientation rule

Stick side is relative to movement, not the screen:

| Move | LEFT probes | RIGHT probes |
| --- | --- | --- |
| N | W | E |
| S | E | W |
| E | N | S |
| W | S | N |

The game also runs assertions for all eight direction/side mappings at startup.

## Run

1. Open the repository folder in Godot 4.7.
2. Run the project (`F5`).
3. Clear each stage with SMASH; the action button becomes **NEXT** through Stage 11 and **REPLAY** after Stage 12.

Main scene:

`res://src/main.tscn`

Base game flow:

`res://src/main.gd`

Grant Demo runtime:

`res://src/grant_demo.gd`

Temporary audio/feel layer:

`res://src/audio_feedback.gd`

## Key smoke tests

### Stage 1 temperature tutorial

From C5 use **E2**:

- Watermelon A5 -> **COLDER**
- Watermelon E5 -> **HOTTER**, ending on E5 ready to SMASH

If COLDER, use **W4**, then SMASH at A5. This guarantees PAR 2.

### Stage 2 three-value sensor

Use **N2** from C5:

- A1 -> HOTTER
- C4 -> SAME
- E5 -> COLDER

### Stage 5 first KNOCK puzzle

Use **N1L** from C5:

- B4 -> **HOTTER + K1** and the wooden `KOTSU!` cue fires
- A4 / D3 / E4 -> HOTTER with no KNOCK

Contact does **not** stop movement. K1-K4 records which committed step produced the contact.

### Late-stage regression openings

The solver audit for the locked data expects:

`S6 N1R / S7 N2L / S8 N3L / S9 N4L / S10 N2R / S11 N2L / S12 N4R`

Stages 3-12 each have the intended unique best opening. Stage 1 is deliberately tutorial-like; Stage 2 deliberately permits N1/N2 as equivalent best openings.

## Current feel loop

1. **Input**: choose direction + steps, and from Stage 5 onward choose stick side.
2. **Commit**: GO locks input and movement advances one tile at a time.
3. **Knock**: when active, side contact produces `KOTSU! Kx` immediately but movement continues.
4. **Observe**: HOTTER / SAME / COLDER appears after stopping and combines with `+ Kx` when relevant.
5. **Smash**: READY -> SWING -> SMASH/SWISH creates the decision-release beat.
6. **Progress**: successful SMASH advances through the complete 12-stage Grant Demo curve.

All current sounds are runtime-generated placeholders. Final Kenney / itch.io / custom audio can replace them without changing puzzle rules.

## Scope intentionally deferred

- final authored sound assets
- final Kenney / itch.io art
- watermelon burst particles / juice animation
- full stage-select / save progression
- post-Grant mechanics outside the locked v0.4.1 core

## Core principle

> Every move changes both what you know and where you are.
