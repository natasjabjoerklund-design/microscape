extends MeshInstance3D
## Drives a panel's sticker-marker glow from its wall state.
##
## Idle ("red", unsolved) = soft standby glow so the marker is FINDABLE in the
## dark room (you have to spot the sticker to find the camouflaged panel). It
## brightens to amber when the panel's mini-game is solved ("yellow") and turns
## steady green once confirmed at the breaker ("green"). In breaker_mode the exit
## marker glows green only when all three walls are green ("you can leave now").
##
## NOTE: wall letters are scrambled vs. panel node names — Turntable = "B",
## Heat = "C", Auth = "A" (see GameManager / the panel UI scripts). Set `wall`
## to the wall this panel actually solves, not the node's name.

@export var wall: String = ""          # "A" / "B" / "C" (ignored if breaker_mode)
@export var breaker_mode: bool = false # exit marker: lights green when all walls green

const COL_IDLE := Color(1.0, 0.15, 0.12)   # red — unsolved (matches breaker light)
const COL_YELLOW := Color(1.0, 0.7, 0.1)
const COL_GREEN := Color(0.2, 1.0, 0.25)

const ENERGY_IDLE := 0.5
const ENERGY_ON := 3.0

const MARKER_SIZE := 0.28   # a touch bigger so it's easier to spot

var _mat: StandardMaterial3D


func _ready() -> void:
	# Make sure the placard is visible regardless of scene lighting / facing.
	if mesh is QuadMesh:
		var m: QuadMesh = mesh.duplicate()
		m.size = Vector2(MARKER_SIZE, MARKER_SIZE)
		mesh = m

	_mat = material_override as StandardMaterial3D
	if _mat == null:
		push_warning("panel_marker: no StandardMaterial3D override on %s" % name)
		return
	_mat.cull_mode = BaseMaterial3D.CULL_DISABLED  # double-sided insurance

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
		_:  # "red" / unsolved — soft standby glow, still findable
			_set_glow(COL_IDLE, ENERGY_IDLE)


func _update_breaker() -> void:
	if GameManager.all_confirmed():
		_set_glow(COL_GREEN, ENERGY_ON)
	else:
		_set_glow(COL_IDLE, ENERGY_IDLE)


func _set_glow(color: Color, energy: float) -> void:
	_mat.emission = color
	_mat.emission_energy_multiplier = energy
