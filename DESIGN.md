# Microscape — Design Doc

## Premise

You are **Kernel** — the operating-system kernel, personified — trapped inside a microwave that is running a completely normal cook cycle. Nothing is malfunctioning. The danger is mundane and much creepier for it: when the timer hits zero, someone is going to open the door, see popped kernels, and eat them — with no idea one of them is alive in there.

By sheer luck (or dark manufacturer humor), the microwave has an internal safety panel — a smaller mirror of the real control panel on the outside, installed for exactly this freak scenario. That panel is Kernel's only way to fight back from inside.

## Room layout

A square room with four walls, physically:
- **Door wall** — no letter, this is the goal.
- **BackWall** — hosts the internal safety panel ("In case of entrapment") and the turntable-control panel.
- **RightWall** — heat panel.
- **LeftWall** — authentication panel.

There's no Boot step anymore — everything starts live from the moment you spawn: the countdown, the heat gauge, and the turntable's spin. No switch to find first, no safe beat before the pressure starts.

**Important:** the letters A/B/C do **not** track physical wall position — they track *breaker panel light order / which effect fires*, and were explicitly reassigned once by request:
- **A (1st light)** = Authentication (physically on LeftWall) → confirming opens the door and wins.
- **B (2nd light)** = Turntable (physically on BackWall) → confirming just acknowledges it; the platform already stopped for good the moment it was solved.
- **C (3rd light)** = Heat (physically on RightWall) → confirming freezes the heat gauge.

The safety panel's buttons/lights are fully generic (`GameManager.confirm("A"/"B"/"C")`), so relabeling which puzzle owns which letter only required changing which letter each puzzle *reports* — no changes to the panel itself.

## Core loop per wall

Each of A/B/C follows the same two-step pattern:
1. **Solve the small game.** Its light on the safety panel goes from **red → yellow**.
2. **Walk back to the safety panel and press that letter's button.** Light goes **yellow → green**, and a real effect fires immediately (see mapping above).

The three physical buttons on the panel (mirroring a real 3-button Arduino Modulino controller) get reused for different jobs across the game rather than meaning one fixed thing — as "confirm this letter" out in the room, and — while inspecting a specific panel — as that panel's own controls (memory-sequence input, +/- venting, sequence entry, or the turntable's STOP).

## Win / Lose

- **Win:** confirm A on the safety panel (this is the direct trigger, not a separate door click).
- **Lose:** countdown hits `0:00` → "DING", or the heat gauge maxes out → "TOO HOT" — either shows the game-over screen with restart. Default 180s timer, ~110s heat gauge, both tunable, both running from spawn.

## Turntable — Light B (built, redesigned)

The floor is a giant spinning disc (radius 1.8, nearly the whole room) that physically carries the player if they're standing on it — deliberate disorientation. A dedicated **inspect-mode panel** on BackWall is how you interact with it.

**Redesign note:** the original version asked the player to judge the disc's real-world rotation by eye and click Stop at the right moment — but once you're inspecting the panel, the camera switches to a close-up of the panel itself and you can no longer see the disc at all. The mechanic was unplayable as built. Replaced with a fully self-contained mini-game that doesn't depend on seeing the 3D disc:

- Walk close to the panel → prompt → click to inspect → close-up view with a small **rotor lock dial** (`spin_lock_dial.gd`, a custom-drawn `Control`): a fixed ring with 4 tick marks, and a 4-armed cross that spins continuously inside it.
- Press **STOP** (button or key 1/A) to try to freeze the cross with its arms lined up on the ticks. Because both the ticks and the cross have 4-fold symmetry, there are 4 valid stop-windows per revolution, not just 1 — a deliberate difficulty choice (skill-based but not punishing). Miss, and STOP resumes the spin for another attempt.
- Landing it locks the dial (turns green), calls `turntable.lock()` (the real 3D disc stops spinning for good, purely as a visual payoff — the win condition itself lives entirely in the dial), and marks the panel solved (yellow, light B).
- Walk to the safety panel, press B → green (acknowledgment, not the trigger — the platform already stopped).

Dropped along with the old mechanic: the "reveal a code on the disc" idea — turned out to be dead code already (nothing ever read the code it revealed, a leftover from an earlier numeric-keypad design that no longer exists).

This inspect-mode pattern (proximity prompt → focused close-up view → exit via Escape) is generic infrastructure (`inspect_mode.gd`, `inspect_zone.gd`, `inspect_prompt.gd`) reused for the other two panels too — worth remembering for any *future* panel: whatever the mini-game is, it needs to be fully playable from within the close-up view alone, since the wider 3D room isn't visible once you're inspecting.

## Heat — Light C (built: the maker's guide, click-based)

A danger separate from the ding timer: `GameManager.heat` rises from 0 to 100 over ~110 seconds once Boot is pressed (slightly faster than the 180s ding, so it's the more urgent of the two). A full-screen red tint (`heat_overlay.gd`) intensifies as heat rises — always visible, no need to check a gauge. If heat maxes out before this is confirmed, it's a distinct lose screen ("TOO HOT").

**The knob is dropped entirely** — the physical Modulino Knob module was never reliably detected on the I2C bus (see the now-removed "Knob support" section this replaces), and rather than keep fighting flaky hardware, the whole mechanic moved off it. The "maker's guide" story concept survived the redesign, just with a simpler, fully mouse-driven interaction: 5 icon buttons in a row — Kernel, Heat, Pop, Butter, Door — click them directly in the correct order. A **PLAY GUIDE** button reveals the in-fiction story (see below) that names that order, framed as "the life cycle of popcorn" so it's discoverable through story logic rather than memorized cold. Get all 5 right, in order, and it's solved (yellow, light C). **RESET** clears progress if you want to start over — mistakes don't auto-reset, so this is opt-in, not a penalty. This also makes the panel consistent with every other panel in the game, which are all plain clickable buttons.

Button mapping while inspecting (via `press_slot`, physical A/B/C buttons or keys 1/2/3): **1/A = play guide, 2/B = reset.** (Button 3/C has no job here now that clicking an icon *is* the confirm action — there's no separate "point then confirm" step anymore.)

Confirming C at the safety panel freezes the heat gauge for good.

**Narration script + voice-gen prompt:** see below — the script is also generated as actual audio now (`audio/heat_panel_guide_voice.mp3`, wired to an `AudioStreamPlayer` that plays alongside the on-screen text when PLAY GUIDE is pressed).

### Knob support — removed

Built out fully at one point (`ModulinoInput.knob_axis`, a `KNOB_NOT_FOUND` diagnostic, an Arduino-side encoder read in `CountdownTimer.ino`) but the physical module never worked reliably, and debugging pointed at a hardware/wiring-level detection failure rather than anything fixable in software. All of it — Godot parsing, the Arduino sketch's `ModulinoKnob` code, the dial UI — has been removed rather than left half-wired. If a knob-driven mechanic comes back later, it'll need the hardware connection issue solved first before it's worth re-wiring the software side.

## Authentication — Light A (built, now the memory-sequence game)

Its own dedicated panel (on LeftWall) with its own A/B/C buttons (inspect-mode, same pattern), separate from the safety panel's confirm buttons.

**This panel inherited the "3 lights, repeat the pattern" memory game that was originally built for Heat**, once it became clear that was meant to be the door game all along. Fixed length of 3 per round (not escalating), run for 3 rounds: 3 lights (color-matched to the A/B/C buttons) flash a sequence, you repeat it back. A wrong guess just replays that same round — no penalty, no reset of round progress. A counter in the status text tracks it ("1/3 CORRECT" → "2/3 CORRECT"); hitting 3/3 solves it (yellow, light A).

(Earlier this was briefly an escalating-difficulty version — lengths 3/4/5, full reset to round 1 on any mistake — before being replaced by the simpler fixed-length version above. Also earlier had a printed "B-C-A" clue on the safety panel as a findable answer; that was removed since it doesn't fit a game where the panel shows you the sequence itself.)

Confirming A at the safety panel opens the door and wins immediately.

## Voice: the maker's guide (script written, audio not yet generated)

**Script (already shown as on-screen text via `GUIDE_TEXT` in `heat_panel_ui.gd`):**

> "Listen close, little kernel. Point to the KERNEL first — that's you, right now, still yourself. Then the HEAT, because that part's unavoidable. Then — and only then — you'll POP. Add a little BUTTER, why not, you'll have earned it. Last stop: the DOOR. Point there, and go."

**Voice-gen prompt** (for whichever TTS tool renders it — paste the script above as the text, this as the voice/style direction):

> An old, warm, slightly mischievous male inventor's voice — a kindly workshop tinkerer in his 60s, a little gravelly. Speaking just above a whisper, like he's sharing a secret he's not supposed to. Unhurried pacing, a soft chuckle in his tone. General American accent. Should sound like an old recorded message — intimate and reassuring rather than urgent, like he genuinely believes this is going to work out fine for you.

Once there's an audio file, wire it into `HeatPanel`'s inspect UI with an `AudioStreamPlayer` triggered by the PLAY GUIDE button, alongside (or instead of) the on-screen text.

## The Watcher (atmosphere, built)

The door window is "wired glass" (see-through with a dark metal grid, like a real microwave's RF-shielding mesh). Beyond it is a small dim outside room. A black silhouette figure appears at the window roughly every 17 seconds (±2s jitter), stays ~2.5s, then vanishes. Pure atmosphere, not tied to any puzzle.

## Visual style (built)

- Left/right/back walls: procedural shader (`wall_panel.gdshader`) — dark gunmetal panels, seam lines, a glowing green accent pinstripe, subtle brushed-metal variation. No image textures, pure math, fully tunable via shader parameters.
- No audio yet at all (hum, clicks, beeps, the ding itself) — still fully open.

## Implementation status (2026-07-04, current)

**Built and working:** no Boot step — countdown, heat gauge, and turntable spin all start live from spawn. Three inspect-mode panels, each with a distinct mechanic: turntable (light B) is a rotor-lock timing dial, heat (light C) is a 5-icon click-in-order story puzzle, authentication (light A) is a 3-round memory-repeat game. The safety panel (3 lights + 3 generic confirm buttons) tracks red→yellow→green per light and fires real effects (A opens the door and wins, B is acknowledgment only since the platform already physically stopped, C freezes the heat gauge). Countdown display, heat overlay, win/lose end screen (three endings: escaped, dinged, overheated), procedural wall shader, wired-glass door + outside room + watcher figure, textured turntable floor.

**Removed along the way** (kept here so old references in chat history don't cause confusion): the numeric keypad, the standalone 3D turntable Stop button, the turntable's code-reveal mechanic, the printed "B-C-A" clue on the safety panel, the escalating-difficulty version of the door's memory game, the needle-in-a-drifting-zone heat game, the knob-pointer-arrow heat game, and all knob/`ModulinoKnob` support on both the Godot and Arduino sides.

**Known rough edges:**
- Exact 3D panel positions on all three walls are reasonable guesses, not verified in-editor.
- The two side-wall panels (Heat, Auth) needed hand-written rotation matrices so their inspect-cameras face the right way — double-checked via cross products rather than trusting rotation-angle sign conventions from memory, but worth confirming those cameras actually frame their panels correctly.
- Heat rate (110s to max) and the door's memory-round timing are easy-to-retune first guesses, not tested for feel.
- Heat's 5 icons are plain colored buttons with text labels, no real art yet.
