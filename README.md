# SUIKAWARI: BLIND SMASH

A solo deduction puzzle inspired by Japanese suikawari.

## Current prototype

The prototype now contains the first **five solver-verified v0.4.1 stages** in a data-driven sequence.

- Godot 4.7 project
- 5x5 board
- Player starts at **C5** in Stages 1-5
- Hidden watermelon is randomized among each stage's candidate positions
- Choose a direction and **1-4 steps**
- Press **GO** to commit
- Movement resolves one tile at a time at 0.20 seconds per step
- Read **HOTTER / SAME / COLDER** after stopping
- Each completed move is written to the observation log
- Stand on the candidate you believe is correct and press **SMASH**
- Clear a stage and the RESET button becomes **NEXT**
- Temporary procedural footsteps, temperature tones, KNOCK, and SMASH feedback are included

The true watermelon position is never displayed before a successful smash.

## v0.4.1 stages currently implemented

| Stage | Candidates | PAR | Stick | Intended discovery |
| --- | --- | ---: | --- | --- |
| 1 | A5 / E5 | 2 | Off | Moving is a question |
| 2 | A1 / C4 / E5 | 3 | Off | SAME is useful information |
| 3 | A1 / A4 / C2 / D5 | 3 | Off | Step count is part of the question |
| 4 | A2 / D2 / D3 | 3 | Off | The best question is not always north |
| 5 | A4 / B4 / D3 / E4 | 3 | **On** | First real KNOCK puzzle |

Stages 1-4 deliberately hide the stick controls. Stage 5 reveals LEFT / RIGHT as a new third input.

Stage definitions live in:

`res://src/stage_catalog.gd`

Reusable stage data model:

`res://src/stage_data.gd`

## Stick orientation rule

Stick side is relative to movement, not the screen:

| Move | LEFT probes | RIGHT probes |
| --- | --- | --- |
| N | W | E |
| S | E | W |
| E | N | S |
| W | S | N |

The game runs assertions for all eight direction/side mappings at startup.

## Run

1. Open the repository folder in Godot 4.7.
2. Run the project (`F5`).
3. Clear Stages 1-4 to reach the first KNOCK puzzle in Stage 5.

Main scene:

`res://src/main.tscn`

Main game flow:

`res://src/main.gd`

Temporary audio/feel layer:

`res://src/audio_feedback.gd`

## Smoke tests

### Stage 1

A guaranteed opening is **E2** from C5:

- Watermelon A5 -> **COLDER**
- Watermelon E5 -> **HOTTER**, and the player ends on E5 ready to SMASH

If the result is COLDER, use **W4**, then SMASH at A5. This guarantees a clear within PAR 2.

### Stage 2 sensor check

Use **N2** from C5:

- A1 -> HOTTER
- C4 -> SAME
- E5 -> COLDER

This verifies the three-value temperature sensor.

### Stage 5 KNOCK check

The first intended move is **N1L** from C5.

- B4 -> **HOTTER + K1** and the wooden `KOTSU!` cue fires
- A4 / D3 / E4 -> HOTTER with no KNOCK

Because the hidden watermelon is randomized, reset/replay Stage 5 until the B4 branch appears when specifically smoke-testing KNOCK.

The important behavior is that contact does **not** stop movement. For longer later-stage moves, K1-K4 records which committed step produced the contact.

## Current feel loop

1. **Input**: choose direction + steps, and from Stage 5 onward choose stick side.
2. **Commit**: GO locks input and movement advances one tile at a time.
3. **Knock**: when active, side contact produces `KOTSU! Kx` immediately but movement continues.
4. **Observe**: HOTTER / SAME / COLDER appears after stopping and combines with `+ Kx` when relevant.
5. **Smash**: READY -> SWING -> SMASH/SWISH creates the decision-release beat.
6. **Progress**: successful SMASH advances to the next stage.

All current sounds are runtime-generated placeholders. Final Kenney / itch.io / custom audio can replace them without changing puzzle rules.

## Scope intentionally deferred

- final authored sound assets
- final Kenney / itch.io art
- watermelon burst particles / juice animation
- Stages 6-12
- full stage select / save progression

The data-driven core is now ready to extend through the rest of the locked v0.4.1 set.

## Core principle

> Every move changes both what you know and where you are.
