extends CanvasLayer
class_name InspectPrompt

@onready var label: Label = $PromptLabel


func _ready() -> void:
	add_to_group("inspect_prompt")
	label.visible = false
	InspectMode.entered.connect(func(_camera): hide_text())


func show_text(text: String) -> void:
	label.text = text
	label.visible = true


func hide_text() -> void:
	label.visible = false
