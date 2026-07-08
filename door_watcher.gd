extends Node3D
class_name DoorWatcher

@export var interval_seconds: float = 17.0
@export var interval_jitter: float = 2.0
@export var visible_duration: float = 5.0

@onready var watcher: Node3D = $Watcher

var _timer: float = 0.0
var _showing: bool = false


func _ready() -> void:
	watcher.visible = false
	_timer = _next_interval()


func _process(delta: float) -> void:
	_timer -= delta
	if _timer > 0.0:
		return

	if _showing:
		watcher.visible = false
		_showing = false
		_timer = _next_interval()
	else:
		watcher.visible = true
		_showing = true
		_timer = visible_duration


func _next_interval() -> float:
	return interval_seconds + randf_range(-interval_jitter, interval_jitter)
