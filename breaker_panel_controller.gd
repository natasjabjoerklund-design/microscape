extends Node
class_name BreakerPanelController

@export var light_a_path: NodePath
@export var light_b_path: NodePath
@export var light_c_path: NodePath
@export var color_red: Material
@export var color_yellow: Material
@export var color_green: Material

var _lights: Dictionary = {}


func _ready() -> void:
	_lights = {
		"A": get_node(light_a_path),
		"B": get_node(light_b_path),
		"C": get_node(light_c_path),
	}
	GameManager.wall_state_changed.connect(_on_wall_state_changed)
	for wall in _lights.keys():
		_update_light(wall, GameManager.wall_states.get(wall, "red"))


func _on_wall_state_changed(wall: String, state: String) -> void:
	_update_light(wall, state)


func _update_light(wall: String, state: String) -> void:
	var light: MeshInstance3D = _lights.get(wall)
	if not light:
		return
	match state:
		"red":
			light.material_override = color_red
		"yellow":
			light.material_override = color_yellow
		"green":
			light.material_override = color_green
