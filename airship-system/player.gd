extends CharacterBody3D

@onready var collision_shape: CollisionShape3D = $CollisionShape3D

@onready var neck: Node3D = $neck
@onready var player_camera: Camera3D = $neck/player_camera
var SENSITIVITY := 0.01

@onready var interact_ray: RayCast3D = $neck/player_camera/interact_ray

var is_piloting := false
var is_seating := false

var SPEED := 5.0
const JUMP_VELOCITY = 5

#main functions
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel") and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif Input.is_action_just_pressed("ui_cancel") and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			rotate_y(-event.relative.x * SENSITIVITY)
			player_camera.rotate_x(-event.relative.y * SENSITIVITY)
			player_camera.rotation.x =clamp(player_camera.rotation.x, deg_to_rad(-60), deg_to_rad(60))
	
	if Input.is_action_just_pressed("E"):
		if interact_ray.is_colliding():
			var collider = interact_ray.get_collider()
			for group in collider.get_groups():
				match group:
					"pilot_seat":
						_pilot_airship(collider)

func _physics_process(delta: float) -> void:
	#wont run if the player is piloting an airship or if they are seating
	if is_piloting == true or is_seating == true:
		return
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("A", "D", "W", "S")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

#extra functions
func _pilot_airship(target_airship):
	if is_piloting == false:
		is_piloting = true
		collision_shape.disabled = true
		global_position = target_airship.global_position
		reparent(target_airship)
		target_airship.get_parent().player_driving = self
	elif is_piloting == true:
		is_piloting = false
		collision_shape.disabled = false
		target_airship.get_parent().player_driving = null
		reparent(get_tree().root)
		var current_y = global_rotation.y
		global_rotation = Vector3(0, current_y, 0)
