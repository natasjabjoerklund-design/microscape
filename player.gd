extends CharacterBody3D

@export var speed: float = 5.0
@export var mouse_sensitivity: float = 0.002
@export var interaction_range: float = 3.0
@export var modulino_move_scale: float = 0.4  # tilt-driven move speed relative to keyboard, at full tilt
@export var modulino_turn_speed: float = 3.0  # radians/sec at full spin (gyro yaw)

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var interaction_ray: RayCast3D = $Head/Camera3D/InteractionRay

var input_enabled: bool = true


func _ready() -> void:
	add_to_group("player")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(event: InputEvent) -> void:
	if not input_enabled:
		return

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		head.rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if event.is_action_pressed("interact") and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_interact()


func _physics_process(delta: float) -> void:
	var input_dir: Vector2 = Vector2.ZERO
	if input_enabled:
		input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
		input_dir.y -= ModulinoInput.move_axis * modulino_move_scale  # forward tilt = negative y, same as move_forward
		input_dir.x += ModulinoInput.strafe_axis * modulino_move_scale  # right tilt = positive x, same as move_right
		input_dir = input_dir.limit_length(1.0)

		head.rotate_y(ModulinoInput.look_axis * modulino_turn_speed * delta)  # flipped: gyro yaw's sign was opposite to the mouse's convention

	var direction: Vector3 = (head.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	# Apply gravity
	if not is_on_floor():
		velocity.y -= 9.8 * delta

	move_and_slide()


func _interact() -> void:
	if interaction_ray.is_colliding():
		var collider: Node = interaction_ray.get_collider()
		if collider.is_in_group("interactable"):
			AudioManager.play_click()
			collider.interact()
