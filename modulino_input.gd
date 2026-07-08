extends Node

# Receives packets from tools/arduino_bridge.py (forwarded from the UNO Q
# over serial):
#   "<move>,<strafe>,<look>" - continuous analog axes from Modulino
#                     Movement, each in [-1, 1], blended with keyboard/
#                     mouse in player.gd. move/strafe come from tilting
#                     (accelerometer); look comes from flatly spinning
#                     the board (gyroscope yaw) and turns the camera.
#   "BTN_A"/"BTN_B"/"BTN_C" - a Modulino Buttons press. Turned into a real
#                     1/2/3 key-tap event, so each physical button is
#                     indistinguishable from pressing that number key on
#                     a keyboard.
#
# Keys 1/2/3 (real or simulated) are routed contextually below: while
# inspecting a panel they drive that panel's controls, otherwise they mirror
# the breaker panel's A/B/C confirm buttons.

const PORT := 4243

const BUTTON_KEYCODES := {
	"BTN_A": KEY_1,
	"BTN_B": KEY_2,
	"BTN_C": KEY_3,
}

const SLOT_KEYCODES := {
	KEY_1: 0,
	KEY_2: 1,
	KEY_3: 2,
}
const SLOT_LETTERS := ["A", "B", "C"]

var move_axis: float = 0.0  # +1 = tilt forward, -1 = tilt backward
var strafe_axis: float = 0.0  # +1 = tilt right, -1 = tilt left
var look_axis: float = 0.0  # +1 = spinning right, -1 = spinning left

var _udp := PacketPeerUDP.new()


func _ready() -> void:
	_udp.bind(PORT)


func _process(_delta: float) -> void:
	while _udp.get_available_packet_count() > 0:
		var text := _udp.get_packet().get_string_from_utf8().strip_edges()

		if BUTTON_KEYCODES.has(text):
			_simulate_key_tap(BUTTON_KEYCODES[text])
			continue

		var parts := text.split(",")
		if parts.size() == 3:
			move_axis = clamp(parts[0].to_float(), -1.0, 1.0)
			strafe_axis = clamp(parts[1].to_float(), -1.0, 1.0)
			look_axis = clamp(parts[2].to_float(), -1.0, 1.0)


func _simulate_key_tap(keycode: Key) -> void:
	var down := InputEventKey.new()
	down.keycode = keycode
	down.pressed = true
	Input.parse_input_event(down)

	var up := InputEventKey.new()
	up.keycode = keycode
	up.pressed = false
	Input.parse_input_event(up)


func _input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	if not SLOT_KEYCODES.has(event.keycode):
		return
	_trigger_slot(SLOT_KEYCODES[event.keycode])


func _trigger_slot(slot: int) -> void:
	AudioManager.play_click()

	if InspectMode.active:
		_dispatch_to_active_panel(slot)
		return

	# Only button 1 enters inspection - 2 and 3 should keep their normal
	# breaker-panel-confirm role even when standing near a panel.
	if slot == 0 and InspectMode.nearby_zone:
		InspectMode.nearby_zone.enter_inspection()
		return

	GameManager.confirm(SLOT_LETTERS[slot])


func _dispatch_to_active_panel(slot: int) -> void:
	var heat_ui: Node = get_tree().get_first_node_in_group("heat_panel_ui")
	if heat_ui and heat_ui.visible:
		heat_ui.press_slot(slot)
		return

	var auth_ui: Node = get_tree().get_first_node_in_group("auth_panel_ui")
	if auth_ui and auth_ui.visible:
		auth_ui.press_letter(SLOT_LETTERS[slot])
		return

	var turntable_ui: Node = get_tree().get_first_node_in_group("turntable_panel_ui")
	if turntable_ui and turntable_ui.visible:
		turntable_ui.press_slot(slot)
		return

	var breaker_ui: Node = get_tree().get_first_node_in_group("breaker_panel_ui")
	if breaker_ui and breaker_ui.visible:
		breaker_ui.press_letter(SLOT_LETTERS[slot])
