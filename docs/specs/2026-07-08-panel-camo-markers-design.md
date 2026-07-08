# Microscape — Panel Camouflage + Sticker Markers

**Date:** 2026-07-08
**Status:** Approved design, ready for implementation plan

## Problem

The three inspect panels (Turntable / Heat / Auth-door) share one flat material,
`Material_console` (solid dark grey, RGB 0.09/0.10/0.11, no texture). Against the
now heavily-textured sci-fi wall they read as blank black voids — you can't tell
what they are, and the one textured panel (the breaker, using `breaker_panel.png`)
looks completely different from the rest. There is no consistent visual language
that (a) hides the panels into the wall as a find-them challenge, or (b) lets the
player distinguish and navigate between panels once found.

## Goal

1. Give all four panels one shared textured surface so they **camouflage into the
   wall** — finding them becomes an observation task.
2. Put a **unique flat sticker marker above each panel** so, once spotted, each
   panel is identifiable at a glance. The sticker is the *only* differentiator.
3. **Reuse the same icons inside the breaker panel UI** so the room markers and the
   breaker's per-wall buttons visibly match, teaching the association wordlessly.

This is a pure presentation layer. It does not touch puzzle logic or `GameManager`
state — it rides on signals that already exist.

## Icon mapping

| Icon   | Panel / Wall            | In-room marker        | Breaker UI reuse      |
|--------|-------------------------|-----------------------|-----------------------|
| Circle | Turntable (Wall A)      | `marker_turntable.png`| `ButtonA` icon        |
| Flame  | Heat (Wall B)           | `marker_heat.png`     | `ButtonB` icon        |
| Lock   | Auth / door (Wall C)    | `marker_auth.png`     | `ButtonC` icon        |
| Exit   | Breaker (safety hub)    | `marker_breaker.png`  | Panel header (opt.)   |

There are exactly three puzzle walls (A/B/C) mirrored in the breaker UI; the exit
icon is the breaker's own marker and does not map to a wall button.

## Design

### 1. Shared panel surface (camouflage)

- New texture asset `textures/panel_camo.png`: a grimy, recessed, bolted access
  hatch that reads like the surrounding wall. Dark, gritty, worn 90s-appliance
  direction. **No baked text or labels.** Single flat panel (not tiling).
- Introduce one shared `Material_panel` (StandardMaterial3D, `albedo_texture` =
  `panel_camo.png`, metallic ~0.4, roughness ~0.5).
- Repoint all four panel meshes to `Material_panel`:
  - `Interactables/TurntablePanel/PanelMesh` (was `Material_console`)
  - `Interactables/HeatPanel/PanelMesh` (was `Material_console`)
  - `Interactables/AuthPanel/PanelMesh` (was `Material_console`)
  - `Interactables/BreakerPanel/CaseMesh` (was `Material_breaker_panel`)
- `Material_console` and `Material_breaker_panel` become unused; `breaker_panel.png`
  is left in `textures/` but no longer referenced.
- Result: all four panels are visually identical and melt into the wall. The
  sticker above each is the only way to find or identify it.

### 2. Sticker markers (four flat objects)

- Geometry: a small flat quad (~0.20 m) sitting flush to the wall, centered just
  above each panel's top edge. Panels are 0.6×0.6×0.08 with center y≈1.4, so the
  top edge is at y≈1.70; place the marker centered near y≈1.85 on the same wall
  plane, pushed very slightly proud of the wall to avoid z-fighting. Each marker is
  a child of its panel's `Node3D` (or a sibling under `Interactables`) so it inherits
  the wall orientation — the Heat and Auth panels are rotated onto side walls, so
  the marker must copy the panel's basis.
- Four new sticker textures, each a **worn factory-label with a transparent
  background** (alpha), low-contrast and grimy so it hides by default:
  `marker_turntable.png` (circle), `marker_heat.png` (flame),
  `marker_auth.png` (lock), `marker_breaker.png` (exit).
- Each marker gets its own StandardMaterial3D: `albedo_texture` = the sticker,
  `transparency` = alpha, `emission_enabled` = true, `emission_texture` = the same
  sticker (so only the icon glows), `emission_energy_multiplier` starting low.

#### Glow-when-active wiring

- New script `panel_marker.gd` (~15–20 lines) on each marker. Exports its wall id
  (`"A"`/`"B"`/`"C"`, or a special `"breaker"` mode).
- On ready it connects to `GameManager.wall_state_changed(wall, state)` and sets its
  own initial state from `GameManager.wall_states`.
- State → emission mapping:
  - `red`   → emission near-off / very dim (grimy, a hunt)
  - `yellow`→ warm glow (panel's mini-game solved)
  - `green` → steady green glow (confirmed at the breaker)
- The breaker marker (`"breaker"` mode) listens to all wall states and glows green
  once A, B and C are all green ("you can leave now"); otherwise stays dim.
- Emission is driven by adjusting `emission` color and `emission_energy_multiplier`
  on the marker's material at runtime; the sticker's alpha keeps the glow to the
  icon shape.

### 3. Reuse icons in the breaker UI

- In `breaker_panel_ui.gd`, assign each wall button its matching sticker as the
  button icon (or an overlaid `TextureRect`), reusing the exact same PNGs:
  `ButtonA` → circle, `ButtonB` → flame, `ButtonC` → lock. Now the room marker and
  the breaker control visibly match.
- Optionally display the exit icon as the breaker panel's header/title.
- These are 2D Control textures pointing at the same texture files — no new assets.

## Assets required (via Summer Studio workflow)

Five new images. Prompts written by Claude, generated by Natasja in Summer Studio,
downloaded to `~/Downloads`, then copied into `textures/` and wired in. **No baked
text/labels in any prompt** (project convention — text stays as live nodes).

1. `panel_camo.png` — shared camouflage panel surface.
2. `marker_turntable.png` — circle sticker (transparent bg).
3. `marker_heat.png` — flame sticker (transparent bg).
4. `marker_auth.png` — lock sticker (transparent bg).
5. `marker_breaker.png` — exit sticker (transparent bg).

## Scope guard / non-goals

- No changes to puzzle logic, `GameManager` state, or the inspect-mode system.
- Only new script is the small `panel_marker.gd` glow driver.
- Not adding sound, animation, or new interactions to the markers — they are visual.

## Open verification items (confirm during implementation)

- Exact marker transform per panel (the Heat and Auth panels are rotated onto side
  walls — copy each panel's basis, offset locally in +Y and slightly +Z-of-wall).
- Confirm `GameManager` exposes an all-green check (or compute it in the marker
  script from `wall_states`).
- Confirm StandardMaterial3D emission masks correctly through the sticker alpha in
  this project's Godot 4.6 setup; fall back to a separate emission mask texture if
  the alpha bleeds.
