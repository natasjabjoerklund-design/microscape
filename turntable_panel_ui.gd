extends CanvasLayer
class_name TurntablePanelUI

@export var my_camera_path: NodePath
@export var turntable_path: NodePath

@onready var my_camera: Camera3D = get_node(my_camera_path)
@onready var turntable: TurntablePuzzle = get_node(turntable_path)
@onready var status_label: Label = $Panel/StatusLabel
@onready var stop_button: Button = $Panel/StopButton
@onready var dial: SpinLockDial = $Panel/Dial


func _ready() -> void:
	add_to_group("turntable_panel_ui")
	visible = false
	InspectMode.entered.connect(_on_entered)
	InspectMode.exited.connect(_on_exited)
	stop_button.pressed.connect(_on_stop_pressed)
	stop_button.pressed.connect(AudioManager.play_click)
	dial.aligned.connect(_on_aligned)


func _process(_delta: float) -> void:
	if not visible:
		return
	if dial.solved:
		status_label.text = "ROTOR LOCKED"
	elif dial.spinning:
		status_label.text = "STOP THE ROTOR ON THE MARKS"
	else:
		status_label.text = "MISSED — STOP TO RESUME"


func _on_entered(camera: Camera3D) -> void:
	visible = camera == my_camera


func _on_exited() -> void:
	visible = false


func _on_stop_pressed() -> void:
	dial.stop()


func _on_aligned() -> void:
	turntable.lock()
	GameManager.mark_solved("B")


func press_slot(_index: int) -> void:
	dial.stop()
