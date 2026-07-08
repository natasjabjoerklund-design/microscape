# Implementation Plan — Panel Camouflage + Sticker Markers

Spec: `docs/specs/2026-07-08-panel-camo-markers-design.md`
Date: 2026-07-08

## Phase 0 — Assets (Natasja generates in Summer Studio, in parallel)

Five images. Prompts below. Download each to `~/Downloads`, tell Claude the
filename, Claude copies into `textures/` and wires it. Stickers need a
**transparent background**. No baked text in any image.

Long pole — start these first. Phases 1 and 3 can proceed with placeholders before
the art lands.

## Phase 1 — Shared camo panel material (no art dependency; can use placeholder)

1. Add `panel_camo.png` to `textures/` (once generated) + its `.import`.
2. In `main.tscn`, add `ExtResource` for `panel_camo.png`.
3. Add `Material_panel` (StandardMaterial3D): `albedo_texture` = panel_camo,
   metallic 0.4, roughness 0.5.
4. Repoint all four panel meshes' `material_override` to `Material_panel`:
   - `TurntablePanel/PanelMesh`, `HeatPanel/PanelMesh`, `AuthPanel/PanelMesh`
     (were `Material_console`)
   - `BreakerPanel/CaseMesh` (was `Material_breaker_panel`)
5. Leave `Material_console` / `Material_breaker_panel` defined but unused.
6. **Checkpoint:** all four panels show the same textured surface, no longer black.

## Phase 2 — Marker meshes, materials, placement

1. Add the four sticker textures + `.import` to `textures/`.
2. One `QuadMesh` sub-resource (~0.20 × 0.20) reused by all four markers.
3. Four StandardMaterial3D marker materials: `albedo_texture` = sticker,
   `transparency = 1` (alpha), `emission_enabled = true`,
   `emission_texture` = sticker, `emission_energy_multiplier` = 0.0 (start dim).
4. Add a `Marker` MeshInstance3D as a child of each panel `Node3D`, so it inherits
   the wall orientation (critical — Heat/Auth panels are rotated onto side walls).
   Local offset: +Y so it sits just above the panel top edge (panel is 0.6 tall,
   center local y≈0 → marker local y≈+0.42), and a small +Z-of-wall offset (~+0.01)
   to sit proud and avoid z-fighting.
5. Breaker marker (exit) added the same way as a child of `BreakerPanel`.
6. **Checkpoint:** each panel has a visible sticker above it, correctly oriented on
   all four walls; verify the two side-wall panels aren't rotated flat/sideways.

## Phase 3 — `panel_marker.gd` glow driver

1. New script `panel_marker.gd` on each marker MeshInstance3D.
2. `@export var wall: String` ("A"/"B"/"C") and `@export var breaker_mode: bool`.
3. In `_ready`: grab the material (duplicate so each instance is independent),
   connect `GameManager.wall_state_changed`, apply initial state from
   `GameManager.wall_states`.
4. `_apply(state)`:
   - red → emission dim (energy ~0.0–0.2, base grimy tint)
   - yellow → warm glow (energy ~2.0, amber emission)
   - green → steady green glow (energy ~2.0, green emission)
5. Breaker mode: on any wall change, if all of A/B/C are green → green glow, else
   dim. (Compute from `GameManager.wall_states`; add an all-green helper on
   GameManager only if one doesn't already exist.)
6. **Checkpoint:** solving a panel (red→yellow) lights its marker; confirming at the
   breaker (yellow→green) turns it green; all-green lights the exit marker.

## Phase 4 — Reuse icons in breaker UI

1. In `breaker_panel_ui.gd` (or the `.tscn` for the breaker UI), set each button's
   icon to the matching sticker: `ButtonA`→circle, `ButtonB`→flame, `ButtonC`→lock.
   Use `Button.icon` or an overlaid `TextureRect`.
2. Optionally add the exit icon to the breaker panel header.
3. **Checkpoint:** breaker buttons show the same icons as the room markers.

## Phase 5 — Verify (Natasja playtests in engine)

- All four panels camouflaged, findable only by their stickers.
- Markers correctly oriented on all four walls.
- Glow tracks red/yellow/green per wall; exit lights when all solved.
- Breaker buttons match room markers.
- No z-fighting, no broken cameras, no console errors.

---

## Asset prompts (Phase 0)

Art direction: dark, gritty, realistic worn 90s-appliance / industrial sci-fi.
Worn dark metal, grime, scratches, dim moody lighting. NO text or labels anywhere.

### 1. panel_camo.png — shared camouflage panel surface
> Flat front-facing square worn metal access hatch panel, recessed bolted frame,
> heavy grime and scratches, dark gunmetal and rust, matching a grimy industrial
> sci-fi wall, subtle surface detail, evenly lit, no text, no labels, no logos,
> photoreal game texture, square.

### 2. marker_turntable.png — circle sticker
> A single small worn industrial warning sticker showing one simple bold circle /
> ring symbol, faded stamped ink, scratched and grimy, isolated on a fully
> transparent background, no text, no border box, centered, top-down flat.

### 3. marker_heat.png — flame sticker
> A single small worn industrial warning sticker showing one simple bold flame /
> heat symbol, faded stamped ink, scratched and grimy, isolated on a fully
> transparent background, no text, no border box, centered, top-down flat.

### 4. marker_auth.png — lock sticker
> A single small worn industrial warning sticker showing one simple bold padlock /
> lock symbol, faded stamped ink, scratched and grimy, isolated on a fully
> transparent background, no text, no border box, centered, top-down flat.

### 5. marker_breaker.png — exit sticker
> A single small worn industrial warning sticker showing one simple bold running-man
> exit / door symbol, faded stamped ink, scratched and grimy, isolated on a fully
> transparent background, no text, no border box, centered, top-down flat.
