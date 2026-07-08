extends Node

@onready var beep: AudioStreamPlayer = $Beep


func _ready() -> void:
	GameManager.wall_state_changed.connect(_on_wall_state_changed)


func _on_wall_state_changed(_wall: String, state: String) -> void:
	if state == "yellow":
		beep.play()
