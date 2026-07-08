extends Interactable
class_name BreakerPanelButton

@export var wall_id: String = "A"


func interact() -> void:
	GameManager.confirm(wall_id)
