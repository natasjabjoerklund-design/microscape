extends CanvasLayer
class_name HeatOverlay

@onready var tint: ColorRect = $Tint


func _process(_delta: float) -> void:
	var fraction: float = GameManager.heat / GameManager.HEAT_MAX
	tint.color = Color(0.8, 0.1, 0.05, fraction * 0.6)
