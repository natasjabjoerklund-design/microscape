extends Node

signal entered(camera: Camera3D)
signal exited

var active: bool = false
var current_camera: Camera3D = null
var nearby_zone: Node = null

var _player_camera: Camera3D = null


func enter(inspect_camera: Camera3D) -> void:
	if active:
		return
	var player: Node = get_tree().get_first_node_in_group("player")
	if not player:
		return
	_player_camera = player.get_node("Head/Camera3D")
	player.input_enabled = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	inspect_camera.current = true
	current_camera = inspect_camera
	active = true
	entered.emit(inspect_camera)


func exit() -> void:
	if not active:
		return
	var player: Node = get_tree().get_first_node_in_group("player")
	if player:
		player.input_enabled = true
	if _player_camera:
		_player_camera.current = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	active = false
	current_camera = null
	exited.emit()


func _unhandled_input(event: InputEvent) -> void:
	if active and event.is_action_pressed("ui_cancel"):
		exit()
