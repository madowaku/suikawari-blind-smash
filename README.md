# SUIKAWARI: BLIND SMASH

A solo deduction puzzle inspired by Japanese suikawari.

## Current prototype

This repository currently contains the first playable vertical slice for **Stage 1**.

- Godot 4.7 project
- 5x5 board
- Player starts at **C5**
- Watermelon is hidden at **A5** or **E5**
- Choose a direction and **1-4 steps**
- Press **GO**
- Read **HOTTER / COLDER** (SAME is supported by the core rule)
- Stand on the candidate you believe is correct
- Press **SMASH**
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

## Stage 1 test route

A useful smoke test is:

1. From C5 choose **E2** and press GO.
2. If the result is **HOTTER**, you are now at E5 and can SMASH.
3. If the result is **COLDER**, choose **W4**, press GO, then SMASH at A5.

This guarantees a clear within PAR 2 for either hidden position.

## Scope intentionally deferred

The first vertical slice deliberately does **not** include:

- stick-left / stick-right sensor
- KNOCK / Kx
- observation log
- movement animation
- sound effects
- Kenney / itch.io art
- Stages 2-12

Those come after Stage 1 is verified in-engine.

## Core principle

> Every move changes both what you know and where you are.
