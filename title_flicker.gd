extends Label

# Occasional quick brightness dip, like an old neon/LED sign settling in -
# fits the electric-appliance theme without being distracting.
@export var min_interval: float = 1.2
@export var max_interval: float = 4.0
@export var dip_min: float = 0.35
@export var dip_max: float = 0.7

var _base_modulate: Color


func _ready() -> void:
	_base_modulate = modulate
	_schedule_next()


func _schedule_next() -> void:
	await get_tree().create_timer(randf_range(min_interval, max_interval)).timeout
	_flicker()
	_schedule_next()


func _flicker() -> void:
	modulate = _base_modulate * Color(1, 1, 1, randf_range(dip_min, dip_max))
	await get_tree().create_timer(randf_range(0.03, 0.08)).timeout
	modulate = _base_modulate
