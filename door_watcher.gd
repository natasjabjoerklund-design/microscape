extends Node3D
class_name DoorWatcher

@export var interval_seconds: float = 17.0
@export var interval_jitter: float = 2.0
@export var visible_duration: float = 5.0

# He slides in from behind the side of the window frame rather than popping
# in, holds while swaying a hair, then slides back out into the dark.
@export var offscreen_x: float = 3.7
@export var slide_time: float = 1.2
@export var hover_amplitude: float = 0.07
@export var hover_speed: float = 1.5

@onready var watcher: Node3D = $Watcher

var _base_y: float = 0.0
var _timer: float = 0.0
var _showing: bool = false
var _hover_time: float = 0.0


func _ready() -> void:
	_base_y = watcher.position.y
	watcher.visible = false
	watcher.position.x = offscreen_x
	_timer = _next_interval()


func _process(delta: float) -> void:
	if _showing:
		_hover_time += delta
		watcher.position.y = _base_y + sin(_hover_time * hover_speed) * hover_amplitude

	_timer -= delta
	if _timer > 0.0:
		return

	if _showing:
		_hide_watcher()
	else:
		_show_watcher()


func _show_watcher() -> void:
	_showing = true
	_timer = visible_duration
	_hover_time = 0.0
	watcher.position.x = offscreen_x
	watcher.position.y = _base_y
	watcher.visible = true
	var tween := create_tween()
	tween.tween_property(watcher, "position:x", 0.0, slide_time) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _hide_watcher() -> void:
	_showing = false
	_timer = _next_interval()
	watcher.position.y = _base_y
	var tween := create_tween()
	tween.tween_property(watcher, "position:x", offscreen_x, slide_time * 0.9) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(func() -> void: watcher.visible = false)


func _next_interval() -> float:
	return interval_seconds + randf_range(-interval_jitter, interval_jitter)
