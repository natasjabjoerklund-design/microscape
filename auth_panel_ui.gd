extends CanvasLayer
class_name AuthPanelUI

@export var my_camera_path: NodePath
@export var rounds_required: int = 3
@export var sequence_length: int = 3

@onready var my_camera: Camera3D = get_node(my_camera_path)
@onready var status_label: Label = $Panel/StatusLabel
@onready var light_a: ColorRect = $Panel/LightA
@onready var light_b: ColorRect = $Panel/LightB
@onready var light_c: ColorRect = $Panel/LightC
@onready var button_a: Button = $Panel/ButtonA
@onready var button_b: Button = $Panel/ButtonB
@onready var button_c: Button = $Panel/ButtonC

const LETTERS := ["A", "B", "C"]
const LIGHT_OFF := Color(0.2, 0.2, 0.2)
const LIGHT_ON := Color(1, 0.9, 0.2)
const LIGHT_PRESSED := Color(1, 0.5, 0.1)

var _lights: Dictionary = {}
var _sequence: Array = []
var _input: Array = []
var _round: int = 0
var solved: bool = false
var _accepting_input: bool = false  # only true once the sequence has finished playing


func _ready() -> void:
	add_to_group("auth_panel_ui")
	visible = false
	_lights = {"A": light_a, "B": light_b, "C": light_c}
	InspectMode.entered.connect(_on_entered)
	InspectMode.exited.connect(_on_exited)
	button_a.pressed.connect(func(): press_letter("A"))
	button_b.pressed.connect(func(): press_letter("B"))
	button_c.pressed.connect(func(): press_letter("C"))
	button_a.pressed.connect(AudioManager.play_click)
	button_b.pressed.connect(AudioManager.play_click)
	button_c.pressed.connect(AudioManager.play_click)


func _on_entered(camera: Camera3D) -> void:
	if camera != my_camera:
		return
	visible = true
	if _round == 0 and not solved:
		_start_round()


func _on_exited() -> void:
	visible = false


func press_letter(letter: String) -> void:
	if solved or not _accepting_input:
		return
	_accepting_input = false

	_input.append(letter)
	_lights[letter].color = LIGHT_PRESSED
	await get_tree().create_timer(0.15).timeout
	_lights[letter].color = LIGHT_OFF

	var i: int = _input.size() - 1
	if _input[i] != _sequence[i]:
		status_label.text = "WRONG — WATCH AGAIN (%d/%d)" % [_round, rounds_required]
		await get_tree().create_timer(0.5).timeout
		_start_round()
		return

	if _input.size() == _sequence.size():
		_round += 1
		if _round >= rounds_required:
			solved = true
			status_label.text = "%d/%d — AUTHENTICATED" % [_round, rounds_required]
			GameManager.mark_solved("A")
			return
		else:
			status_label.text = "%d/%d CORRECT" % [_round, rounds_required]
			await get_tree().create_timer(0.8).timeout
			_start_round()
			return

	_accepting_input = true


func _start_round() -> void:
	_accepting_input = false
	_input.clear()
	_sequence = []
	for i in range(sequence_length):
		_sequence.append(LETTERS[randi() % 3])

	status_label.text = "WATCH... (%d/%d)" % [_round, rounds_required]
	_reset_lights()
	await _play_sequence()
	status_label.text = "REPEAT IT (%d/%d)" % [_round, rounds_required]
	_accepting_input = true


func _play_sequence() -> void:
	for letter in _sequence:
		_lights[letter].color = LIGHT_ON
		await get_tree().create_timer(0.45).timeout
		_lights[letter].color = LIGHT_OFF
		await get_tree().create_timer(0.2).timeout


func _reset_lights() -> void:
	for l in _lights.values():
		l.color = LIGHT_OFF
