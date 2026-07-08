extends CanvasLayer
class_name HeatPanelUI

# Icon identities: 0=Kernel, 1=Heat, 2=Pop, 3=Butter, 4=Door. required_order
# is the correct sequence of *icon identities* (matches the fixed narration),
# but which screen slot shows which icon is shuffled in _shuffle_layout() -
# otherwise the solve order is just "click left to right" and the story
# never needs to be heard at all.
@export var my_camera_path: NodePath
@export var required_order: Array = [0, 1, 2, 3, 4]

const ICON_NAMES := ["KERNEL", "HEAT", "POP", "BUTTER", "DOOR"]
const ICON_COLORS := [
	Color(0.95, 0.85, 0.3),   # Kernel
	Color(1, 0.4, 0.1),       # Heat
	Color(0.95, 0.95, 0.9),   # Pop
	Color(1, 0.9, 0.4),       # Butter
	Color(0.3, 0.85, 0.4),    # Door
]

@onready var my_camera: Camera3D = get_node(my_camera_path)
@onready var status_label: Label = $Panel/StatusLabel
@onready var history_label: Label = $Panel/HistoryLabel
@onready var play_button: Button = $Panel/PlayButton
@onready var reset_button: Button = $Panel/ResetButton
@onready var guide_voice: AudioStreamPlayer = $Panel/GuideVoice
@onready var icon_buttons: Array = [
	$Panel/IconKernel, $Panel/IconHeat, $Panel/IconPop, $Panel/IconButter, $Panel/IconDoor,
]

var solved: bool = false
var _progress: int = 0
var _highlighted: int = 0
var _guide_played: bool = false
var _chosen: Array = []
var _slot_to_icon: Array = [0, 1, 2, 3, 4]  # which icon identity sits in each screen slot


func _ready() -> void:
	add_to_group("heat_panel_ui")
	visible = false
	InspectMode.entered.connect(_on_entered)
	InspectMode.exited.connect(_on_exited)
	play_button.pressed.connect(_on_play_pressed)
	play_button.pressed.connect(AudioManager.play_click)
	reset_button.pressed.connect(_on_reset_pressed)
	reset_button.pressed.connect(AudioManager.play_click)
	for i in range(icon_buttons.size()):
		icon_buttons[i].pressed.connect(_on_icon_pressed.bind(i))
		icon_buttons[i].pressed.connect(AudioManager.play_click)
	_shuffle_layout()


func _process(_delta: float) -> void:
	if not visible:
		return
	if solved:
		status_label.text = "STABILIZED"
	else:
		status_label.text = "%d/%d  [highlighted: %s | need: %s]" % [
			_progress, required_order.size(),
			ICON_NAMES[_slot_to_icon[_highlighted]], ICON_NAMES[required_order[_progress]]
		]


func _on_entered(camera: Camera3D) -> void:
	visible = camera == my_camera
	if visible and not _guide_played and not solved:
		_guide_played = true
		guide_voice.play()


func _on_exited() -> void:
	visible = false
	guide_voice.stop()


func _on_play_pressed() -> void:
	if guide_voice.playing:
		guide_voice.stop()
	else:
		guide_voice.play()


func _on_reset_pressed() -> void:
	if solved:
		return
	_progress = 0
	_highlighted = 0
	_chosen = []
	history_label.text = "CHOSEN: (none yet)"
	_shuffle_layout()


func _shuffle_layout() -> void:
	_slot_to_icon = [0, 1, 2, 3, 4]
	_slot_to_icon.shuffle()
	history_label.text = "CHOSEN: (none yet)"
	_update_highlight()


func _on_icon_pressed(slot: int) -> void:
	if solved:
		return
	var icon: int = _slot_to_icon[slot]
	if icon != required_order[_progress]:
		_flash_wrong()
		return

	_chosen.append(ICON_NAMES[icon])
	history_label.text = "CHOSEN: " + " → ".join(_chosen)

	_progress += 1
	if _progress >= required_order.size():
		solved = true
		status_label.text = "STABILIZED"
		GameManager.mark_solved("C")


func _flash_wrong() -> void:
	history_label.text = "✗ WRONG — TRY ANOTHER ICON"
	await get_tree().create_timer(0.6).timeout
	if not solved:
		history_label.text = "CHOSEN: " + (" → ".join(_chosen) if not _chosen.is_empty() else "(none yet)")


func _cycle_highlight() -> void:
	_highlighted = (_highlighted + 1) % icon_buttons.size()
	_update_highlight()


func _update_highlight() -> void:
	for slot in range(icon_buttons.size()):
		var icon: int = _slot_to_icon[slot]
		icon_buttons[slot].text = ("▶ " if slot == _highlighted else "") + ICON_NAMES[icon]
		icon_buttons[slot].modulate = ICON_COLORS[icon]


func press_slot(index: int) -> void:
	if index == 0:
		_cycle_highlight()
	elif index == 1:
		_on_icon_pressed(_highlighted)
	elif index == 2:
		_on_reset_pressed()
