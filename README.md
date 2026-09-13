# SUIKAWARI: BLIND SMASH

A solo deduction puzzle inspired by Japanese suikawari.

## Current prototype

This repository currently contains the first playable vertical slice for **Stage 1**, plus the first feel/audio pass and the core stick sensor used by later stages.

- Godot 4.7 project
- 5x5 board
- Player starts at **C5**
- Watermelon is hidden at **A5** or **E5**
- Choose a direction, **1-4 steps**, and **LEFT / RIGHT stick side**
- Press **GO** to commit
- Movement resolves **one tile at a time** at 0.20 seconds per step
- Each step has a temporary procedural sand-footstep SFX
- The stick probes one tile to the player's left or right **relative to travel direction**
- If the stick touches the watermelon during movement, the game shows **KOTSU!** and records **K1-K4** for the contact step
- KNOCK has its own temporary procedural wooden-click SFX
- Read **HOTTER / COLDER** (SAME is supported by the core rule)
- HOTTER / COLDER / SAME each have distinct temporary feedback tones
- Each completed move is added to an **observation log** such as `T3 N2L -> HOTTER + K2`
- Stand on the candidate you believe is correct
- Press **SMASH**
- SMASH has a temporary **READY -> SWING -> SMASH/SWISH** timing pass with procedural placeholder SFX
- Stage 1 PAR: **2 turns**

The true watermelon position is randomized on every reset and is never displayed before a successful smash.

## Stick orientation rule

Stick side is relative to movement, not the screen:

| Move | LEFT probes | RIGHT probes |
| --- | --- | --- |
| N | W | E |
| S | E | W |
| E | N | S |
| W | S | N |

The game runs assertions for all eight direction/side mappings at startup so accidental orientation regressions fail loudly during development.

## Run

1. Open the repository folder in Godot 4.7.
2. Run the project (`F6`/`F5` as appropriate).
3. Play Stage 1 from the generated prototype UI.

Main scene:

`res://src/main.tscn`

Main prototype logic:

`res://src/main.gd`

Temporary audio/feel layer:

`res://src/audio_feedback.gd`

## Stage 1 smoke test

A guaranteed route is:

1. From C5 choose **E2L** or **E2R** and press GO.
2. Watch and listen to the player resolve the two committed steps.
3. Confirm the log adds `T1 E2L -> HOTTER` / `COLDER` (or the `R` equivalent).
4. Confirm the temperature result has distinct audio feedback.
5. If the result is **HOTTER**, you are now at E5 and can SMASH.
6. If the result is **COLDER**, choose **W4L** or **W4R**, press GO, then SMASH at A5.
7. Confirm SMASH gives a short wind-up, swing cue, then hit or miss feedback.

This guarantees a clear within PAR 2 for either hidden position.

Stage 1's A5/E5 geometry is intentionally the original temperature tutorial, so it normally does not produce a KNOCK. The stick UI and sensor core are already active; **Stage 5 is the first locked v0.4.1 puzzle designed to make KNOCK part of the solution.**

## Current feel pass

The prototype now establishes the five beats needed for later polish:

1. **Input**: choose direction, steps, and stick side, then preview the route.
2. **Commit**: GO locks input and the move advances one tile at a time with a short footstep cue.
3. **Knock**: if the side probe contacts the watermelon, `KOTSU! Kx` appears immediately but the committed movement continues.
4. **Observe**: HOTTER / SAME / COLDER appears after stopping, combines with `+ Kx` when relevant, and the observation log updates.
5. **Smash**: READY -> SWING -> hit/miss feedback creates a short decision-release beat.

The last movement trail remains visible until the player starts forming the next plan.

All current sounds are deliberately generated at runtime as temporary placeholders. Final Kenney / itch.io / custom audio can replace them later without changing the puzzle rules.

## Scope intentionally deferred

The current slice deliberately does **not** include:

- final authored sound assets
- final Kenney / itch.io art
- watermelon burst particles / juice animation
- Stage 2-12 data/progression

The core `direction + steps + stick side -> movement -> KNOCK -> temperature -> SMASH` loop is now present.

## Core principle

> Every move changes both what you know and where you are.
