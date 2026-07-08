extends CanvasLayer
class_name BreakerPanelUI

@export var my_camera_path: NodePath

@onready var my_camera: Camera3D = get_node(my_camera_path)
@onready var light_a: ColorRect = $Panel/LightA
@onready var light_b: ColorRect = $Panel/LightB
@onready var light_c: ColorRect = $Panel/LightC
@onready var button_a: Button = $Panel/ButtonA
@onready var button_b: Button = $Panel/ButtonB
@onready var button_c: Button = $Panel/ButtonC

const COLOR_RED := Color(1, 0.15, 0.15)
const COLOR_YELLOW := Color(1, 0.85, 0.15)
const COLOR_GREEN := Color(0.15, 1, 0.2)

var _lights: Dictionary = {}


func _ready() -> void:
	add_to_group("breaker_panel_ui")
	visible = false
	_lights = {"A": light_a, "B": light_b, "C": light_c}
	GameManager.wall_state_changed.connect(_on_wall_state_changed)
	InspectMode.entered.connect(_on_entered)
	InspectMode.exited.connect(_on_exited)
	button_a.pressed.connect(func(): GameManager.confirm("A"))
	button_b.pressed.connect(func(): GameManager.confirm("B"))
	button_c.pressed.connect(func(): GameManager.confirm("C"))
	button_a.pressed.connect(AudioManager.play_click)
	button_b.pressed.connect(AudioManager.play_click)
	button_c.pressed.connect(AudioManager.play_click)
	for wall in _lights.keys():
		_update_light(wall, GameManager.wall_states.get(wall, "red"))


func _on_entered(camera: Camera3D) -> void:
	visible = camera == my_camera


func _on_exited() -> void:
	visible = false


func _on_wall_state_changed(wall: String, state: String) -> void:
	_update_light(wall, state)


func press_letter(letter: String) -> void:
	GameManager.confirm(letter)


func _update_light(wall: String, state: String) -> void:
	var light: ColorRect = _lights.get(wall)
	if not light:
		return
	match state:
		"red":
			light.color = COLOR_RED
		"yellow":
			light.color = COLOR_YELLOW
		"green":
			light.color = COLOR_GREEN
