extends Node

signal wall_state_changed(wall: String, state: String)
signal time_expired
signal died_of_heat
signal game_won

const WALLS: Array[String] = ["A", "B", "C"]

const TIMER_SECONDS: float = 180.0
const HEAT_MAX: float = 100.0
const HEAT_RATE: float = HEAT_MAX / 110.0

var wall_states: Dictionary = {"A": "red", "B": "red", "C": "red"}
var time_remaining: float = TIMER_SECONDS
var timer_running: bool = true
var heat: float = 0.0
var heat_rising: bool = true
var game_over: bool = false


func _process(delta: float) -> void:
	if game_over:
		return

	if timer_running:
		time_remaining -= delta
		if time_remaining <= 0.0:
			time_remaining = 0.0
			timer_running = false
			game_over = true
			time_expired.emit()
			return

	if heat_rising:
		heat += HEAT_RATE * delta
		if heat >= HEAT_MAX:
			heat = HEAT_MAX
			heat_rising = false
			game_over = true
			died_of_heat.emit()


func mark_solved(wall: String) -> void:
	if wall_states.get(wall) != "red":
		return
	wall_states[wall] = "yellow"
	wall_state_changed.emit(wall, "yellow")


func confirm(wall: String) -> void:
	if wall_states.get(wall) != "yellow":
		return
	wall_states[wall] = "green"
	wall_state_changed.emit(wall, "green")
	_apply_effect(wall)


func _apply_effect(wall: String) -> void:
	if wall == "C":
		heat_rising = false
	if all_confirmed():
		win()


func all_confirmed() -> bool:
	for w in WALLS:
		if wall_states.get(w) != "green":
			return false
	return true


func win() -> void:
	if game_over:
		return
	game_over = true
	timer_running = false
	game_won.emit()


func get_time_string() -> String:
	var total: int = int(ceil(time_remaining))
	var minutes: int = total / 60
	var seconds: int = total % 60
	return "%d:%02d" % [minutes, seconds]
