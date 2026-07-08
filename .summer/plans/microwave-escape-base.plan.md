---
name: microwave-escape-base
overview: >-
  First-person escape room inside a microwave: movement, mouse look,
  interactable objects, one working button puzzle.
createdAt: '2026-07-04T09:35:05.431Z'
todos:
  - id: player-script
    content: >-
      Write player.gd: first-person WASD movement + mouse look + mouse capture +
      Escape to release
    status: completed
  - id: interactable-system
    content: >-
      Write interactable.gd: base class for clickable objects + interaction
      raycast in player
    status: completed
  - id: button-puzzle
    content: 'Write button_puzzle.gd: a clickable button that toggles a display/light'
    status: completed
  - id: main-scene
    content: >-
      Write main.tscn: microwave box interior with player, walls, floor,
      ceiling, button, display
    status: completed
  - id: input-actions
    content: 'Bind input actions: move_forward/back/left/right, interact, ui_cancel'
    status: completed
  - id: verify
    content: 'Set main scene, runAndVerify, fix any errors'
    status: completed
---
## Microwave Escape Room - Minimum Playable Base

### Scene: res://main.tscn
3D first-person scene inside a microwave interior.

**World root (Node3D):**
- DirectionalLight3D (dim ambient)
- MicrowaveInterior (Node3D)
  - Walls: 4 StaticBody3D boxes (dark gray)
  - Floor: StaticBody3D box (medium gray)
  - Ceiling: StaticBody3D box (dark gray)
  - BackWall: StaticBody3D (the microwave back)
  - DoorWall: StaticBody3D with emissive border (the escape goal)
- Interactables (Node3D)
  - Button: StaticBody3D with button_puzzle.gd + glowing mesh
  - Display: MeshInstance3D (dark panel that changes on button press)
- Player (CharacterBody3D)
  - Head (Node3D) + Camera3D
  - InteractionRay (RayCast3D)
  - CollisionShape3D (capsule)

### Scripts:
- **player.gd**: First-person controller. WASD movement relative to head direction, mouse look with capture, raycast interaction on click. Escape releases mouse.
- **interactable.gd**: Base class with `interact()` virtual method. nodes in group "interactable".
- **button_puzzle.gd**: Extends interactable. Toggles a target node's visibility/material on click.

### Input actions:
- move_forward (W, Up), move_back (S, Down), move_left (A, Left), move_right (D, Right)
- interact (Mouse left button)
- ui_cancel (Escape)

### Verification:
- RunAndVerify: game loads, player can move and look around
- Interaction: click the button, see the display change
