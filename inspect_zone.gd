extends Area3D
class_name InspectZone

@export var inspect_camera_path: NodePath
@export var prompt_text: String = "Click to inspect"

@onready var inspect_camera: Camera3D = get_node(inspect_camera_path)

var _player_in_range: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return
	_player_in_range = true
	InspectMode.nearby_zone = self
	var prompt: Node = get_tree().get_first_node_in_group("inspect_prompt")
	if prompt:
		prompt.show_text(prompt_text)


func _on_body_exited(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return
	_player_in_range = false
	if InspectMode.nearby_zone == self:
		InspectMode.nearby_zone = null
	var prompt: Node = get_tree().get_first_node_in_group("inspect_prompt")
	if prompt:
		prompt.hide_text()


func _unhandled_input(event: InputEvent) -> void:
	if _player_in_range and not InspectMode.active and event.is_action_pressed("interact"):
		AudioManager.play_click()
		enter_inspection()


func enter_inspection() -> void:
	if not _player_in_range or InspectMode.active:
		return
	var prompt: Node = get_tree().get_first_node_in_group("inspect_prompt")
	if prompt:
		prompt.hide_text()
	InspectMode.enter(inspect_camera)
