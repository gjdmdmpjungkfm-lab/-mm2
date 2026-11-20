# Colony: Last Haven

A mobile-first top-down colony simulation prototype made with Lua and LÖVE2D.

## Run

1. Install LÖVE2D.
2. Open the `colony-last-haven` folder as a LÖVE game.
3. The entry point is `main.lua`.

For Android, package the folder as a LÖVE Android project using the official LÖVE Android workflow. The game uses no external image or audio assets yet.

## Current prototype systems

- Procedurally generated 72×72 map with grass, rough ground, rocks, water, trees and stone deposits.
- Three starting colonists with hunger, rest, health, mood and simple autonomous gathering.
- Resource stockpiles for wood, stone, food and cloth.
- Construction: walls, beds, stockpiles, farm plots, workshops, medical rooms and research beacons.
- Growing food from farm plots.
- Research points and five technology unlocks.
- Periodic raids and basic colony defence simulation.
- Save/load to LÖVE's local save directory.
- Touch controls, map panning and zoom; keyboard/mouse support for desktop testing.

## Controls

- Tap **Build**, choose a structure, then tap an empty map tile.
- Tap **People** to inspect colonists.
- Tap **Research** to unlock technologies when enough research points are available.
- Drag the map to pan; use the mouse wheel or +/- keys to zoom on desktop.
- Tap **Pause** or press Space to pause/resume.
- Press **S** to save and **L** to load on desktop.

This is the first playable foundation, not a complete feature-equivalent remake of RimWorld. More simulation systems, content, UI and balancing are intended to be added iteratively.
