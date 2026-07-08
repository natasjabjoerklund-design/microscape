extends MeshInstance3D
## Drives a panel's sticker-marker glow from its wall state.
##
## Grimy / no glow at "red" (a hunt), warm glow at "yellow" (panel solved),
## steady green at "green" (confirmed at the breaker). In breaker_mode the marker
## instead glows green only once all three walls are green ("you can leave now").
##
## NOTE: wall letters are scrambled vs. panel node names — Turntable = "B",
## Heat = "C", Auth = "A" (see GameManager / the panel UI scripts). Set `wall`
## to the wall this panel actually solves, not the node's name.

@export var wall: String = ""          # "A" / "B" / "C" (ignored if breaker_mode)
@export var breaker_mode: bool = false # exit marker: lights when all walls green

const COL_DIM := Color(0.05, 0.05, 0.05)
const COL_YELLOW := Color(1.0, 0.7, 0.1)
const COL_GREEN := Color(0.2, 1.0, 0.25)

const ENERGY_ON := 2.2

var _mat: StandardMaterial3D


func _ready() -> void:
	_mat = material_override as StandardMaterial3D
	if _mat == null:
		push_warning("panel_marker: no StandardMaterial3D override on %s" % name)
		return
	GameManager.wall_state_changed.connect(_on_wall_state_changed)
	if breaker_mode:
		_update_breaker()
	else:
		_apply(GameManager.wall_states.get(wall, "red"))


func _on_wall_state_changed(changed_wall: String, state: String) -> void:
	if breaker_mode:
		_update_breaker()
	elif changed_wall == wall:
		_apply(state)


func _apply(state: String) -> void:
	match state:
		"yellow":
			_set_glow(COL_YELLOW, ENERGY_ON)
		"green":
			_set_glow(COL_GREEN, ENERGY_ON)
		_:  # "red" / anything else — grimy, no glow
			_set_glow(COL_DIM, 0.0)


func _update_breaker() -> void:
	if GameManager.all_confirmed():
		_set_glow(COL_GREEN, ENERGY_ON)
	else:
		_set_glow(COL_DIM, 0.0)


func _set_glow(color: Color, energy: float) -> void:
	_mat.emission = color
	_mat.emission_energy_multiplier = energy
