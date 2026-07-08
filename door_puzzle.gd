extends Node3D
class_name DoorPuzzle

@export var unlocked_material: Material

@onready var rails: Array = [
	$Frame/LeftRail, $Frame/RightRail, $Frame/TopRail, $Frame/BottomRail,
]


func _ready() -> void:
	GameManager.wall_state_changed.connect(_on_wall_state_changed)


func _on_wall_state_changed(wall: String, state: String) -> void:
	if wall == "A" and state == "green" and unlocked_material:
		for rail in rails:
			if rail:
				rail.material_override = unlocked_material
