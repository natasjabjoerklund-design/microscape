extends AudioStreamPlayer


func _ready() -> void:
	stream.loop = true
	play()
