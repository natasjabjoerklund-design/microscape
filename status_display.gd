extends MeshInstance3D
class_name StatusDisplay

@onready var timer_label: Label3D = $TimerLabel


func _process(_delta: float) -> void:
	timer_label.text = GameManager.get_time_string()
