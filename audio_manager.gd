extends Node

var _player: AudioStreamPlayer


func _ready() -> void:
	_player = AudioStreamPlayer.new()
	_player.stream = preload("res://audio/button_click.wav")
	add_child(_player)


func play_click() -> void:
	_player.play()
