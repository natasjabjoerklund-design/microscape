extends Node3D
class_name TurntablePuzzle

@export var spin_speed_degrees: float = 20.0

@onready var visual: Node3D = $TurntableVisual
@onready var riding_area: Area3D = $RidingArea

var spinning: bool = true
var current_angle_degrees: float = 0.0
var solved: bool = false


func _physics_process(delta: float) -> void:
	if not spinning:
		return
	var delta_degrees: float = spin_speed_degrees * delta
	current_angle_degrees = fmod(current_angle_degrees + delta_degrees, 360.0)
	visual.rotation.y = deg_to_rad(current_angle_degrees)
	_carry_riders(delta_degrees)


func _carry_riders(delta_degrees: float) -> void:
	for body in riding_area.get_overlapping_bodies():
		if body.is_in_group("player"):
			var offset: Vector3 = body.global_position - global_position
			offset = offset.rotated(Vector3.UP, deg_to_rad(delta_degrees))
			body.global_position = global_position + offset


func lock() -> void:
	if solved:
		return
	solved = true
	spinning = false
