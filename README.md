# SUIKAWARI: BLIND SMASH

A solo deduction puzzle inspired by Japanese suikawari.

## Current prototype

This repository currently contains the first playable vertical slice for **Stage 1**, plus the first feel/audio pass.

- Godot 4.7 project
- 5x5 board
- Player starts at **C5**
- Watermelon is hidden at **A5** or **E5**
- Choose a direction and **1-4 steps**
- Press **GO** to commit
- Movement resolves **one tile at a time** at 0.20 seconds per step
- Each step has a temporary procedural sand-footstep SFX
- Read **HOTTER / COLDER** (SAME is supported by the core rule)
- HOTTER / COLDER / SAME each have distinct temporary feedback tones
- Each completed move is added to an **observation log**
- Stand on the candidate you believe is correct
- Press **SMASH**
- SMASH now has a temporary **READY -> SWING -> SMASH/SWISH** timing pass with procedural placeholder SFX
- Stage 1 PAR: **2 turns**

The true watermelon position is randomized on every reset and is never displayed before a successful smash.

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

1. From C5 choose **E2** and press GO.
2. Watch and listen to the player resolve the two committed steps.
3. Confirm the log adds `T1 E2 -> HOTTER` or `T1 E2 -> COLDER`.
4. Confirm the temperature result has distinct audio feedback.
5. If the result is **HOTTER**, you are now at E5 and can SMASH.
6. If the result is **COLDER**, choose **W4**, press GO, then SMASH at A5.
7. Confirm SMASH gives a short wind-up, swing cue, then either hit or miss feedback.

This guarantees a clear within PAR 2 for either hidden position.

## Current feel pass

The prototype now establishes the four beats needed for later polish:

1. **Input**: choose direction and steps, preview the route.
2. **Commit**: GO locks input and the move advances one tile at a time with a short footstep cue.
3. **Observe**: HOTTER / SAME / COLDER pops in with a distinct tone, then the observation log updates.
4. **Smash**: READY -> SWING -> hit/miss feedback creates a short decision-release beat.

The last movement trail remains visible until the player starts forming the next plan.

All current sounds are deliberately generated at runtime as temporary placeholders. Final Kenney / itch.io / custom audio can replace them later without changing the puzzle rules.

## Scope intentionally deferred

The current slice deliberately does **not** include:

- stick-left / stick-right sensor
- KNOCK / Kx
- final authored sound assets
- final Kenney / itch.io art
- watermelon burst particles / juice animation
- Stages 2-12

Those come after Stage 1 is verified in-engine.

## Core principle

> Every move changes both what you know and where you are.