extends CanvasLayer
class_name EndScreen

@onready var message_label: Label = $Message
@onready var restart_button: Button = $RestartButton


func _ready() -> void:
	visible = false
	GameManager.game_won.connect(_on_game_won)
	GameManager.time_expired.connect(_on_time_expired)
	GameManager.died_of_heat.connect(_on_died_of_heat)


func _on_game_won() -> void:
	message_label.text = "SYSTEM RESTORED\nYou escaped."
	_show_screen()


func _on_time_expired() -> void:
	message_label.text = "DING.\nTime's up. Someone's coming to eat the popcorn."
	_show_screen()


func _on_died_of_heat() -> void:
	message_label.text = "TOO HOT.\nYou didn't stop the heat in time."
	_show_screen()


func _show_screen() -> void:
	visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var player: Node = get_tree().get_first_node_in_group("player")
	if player:
		player.input_enabled = false


func _unhandled_input(event: InputEvent) -> void:
	if visible and event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_1:
		_on_restart_pressed()


func _on_restart_pressed() -> void:
	AudioManager.play_click()
	get_tree().reload_current_scene()
