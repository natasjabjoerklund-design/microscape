extends Control

const COMBO_WINDOW_MS := 300
const COMBO_KEYS := [KEY_1, KEY_2, KEY_3]

@onready var pop_sound: AudioStreamPlayer = $PopSound

var _starting: bool = false
var _last_press_time := {KEY_1: -1000000, KEY_2: -1000000, KEY_3: -1000000}


func _ready() -> void:
	# Loop by replaying on finish rather than relying on the imported
	# stream's own loop_mode setting - works regardless of how the audio
	# file happens to be imported, and doesn't fail if that metadata isn't
	# set up (e.g. a freshly added file Godot hasn't reprocessed yet).
	pop_sound.finished.connect(pop_sound.play)
	pop_sound.play()


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	if not COMBO_KEYS.has(event.keycode):
		return

	var now: int = Time.get_ticks_msec()
	_last_press_time[event.keycode] = now

	var oldest: int = now
	for key in COMBO_KEYS:
		oldest = min(oldest, _last_press_time[key])

	if now - oldest <= COMBO_WINDOW_MS:
		_on_start_pressed()


func _on_start_pressed() -> void:
	if _starting:
		return
	_starting = true
	AudioManager.play_click()
	get_tree().change_scene_to_file("res://main.tscn")
