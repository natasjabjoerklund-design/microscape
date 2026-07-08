extends Control
class_name SpinLockDial

signal aligned
signal missed

@export var spin_speed_degrees: float = 160.0
@export var tolerance_degrees: float = 8.0

var spinning: bool = true
var current_angle_degrees: float = 0.0
var solved: bool = false


func _process(delta: float) -> void:
	if not spinning:
		return
	current_angle_degrees = fmod(current_angle_degrees + spin_speed_degrees * delta, 90.0)
	queue_redraw()


func stop() -> void:
	if solved:
		return
	spinning = not spinning
	if not spinning:
		_check_alignment()


func _check_alignment() -> void:
	var diff: float = min(current_angle_degrees, 90.0 - current_angle_degrees)
	if diff <= tolerance_degrees:
		solved = true
		aligned.emit()
	else:
		missed.emit()
	queue_redraw()


func _draw() -> void:
	var center: Vector2 = size / 2.0
	var radius: float = min(size.x, size.y) / 2.0 - 6.0

	draw_arc(center, radius, 0, TAU, 48, Color(0.3, 0.9, 0.4, 0.8), 2.0)

	for i in range(4):
		var angle: float = deg_to_rad(i * 90.0)
		var dir: Vector2 = Vector2(cos(angle), sin(angle))
		draw_line(center + dir * (radius - 12.0), center + dir * radius, Color(0.2, 1, 0.3, 1), 4.0)

	var rotor_color: Color = Color(0.2, 1, 0.3, 1) if solved else Color(1, 0.6, 0.15, 1)
	for i in range(4):
		var angle: float = deg_to_rad(current_angle_degrees + i * 90.0)
		var dir: Vector2 = Vector2(cos(angle), sin(angle))
		draw_line(center, center + dir * (radius - 14.0), rotor_color, 4.0)
