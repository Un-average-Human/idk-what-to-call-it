extends CharacterBody3D

#camera movement variables
@onready var neck: Node3D = $neck
@onready var player_camera: Camera3D = $neck/player_camera
var SENSITIVITY := 0.01

#grabbing system variables
var left_grabbed_obj: RigidBody3D = null
var right_grabbed_obj: RigidBody3D = null
@onready var right_hand: Marker3D = $neck/player_camera/right_hand
@onready var left_hand: Marker3D = $neck/player_camera/left_hand

#interaction variables
@onready var interact_ray: RayCast3D = $neck/player_camera/interact_ray

#pilot and seat variables
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
var is_piloting := false
var is_seating := false

#movement variables
var SPEED := 5.0
const JUMP_VELOCITY = 5

# money
var wallet: float = 500.0: set = _set_wallet

#airships
var owned_airships: Array = []

#main functions
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	#lock mouse
	if Input.is_action_just_pressed("ui_cancel") and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif Input.is_action_just_pressed("ui_cancel") and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			rotate_y(-event.relative.x * SENSITIVITY)
			player_camera.rotate_x(-event.relative.y * SENSITIVITY)
			player_camera.rotation.x =clamp(player_camera.rotation.x, deg_to_rad(-60), deg_to_rad(60))

#left hand
	if Input.is_action_just_pressed("F"):
		if left_grabbed_obj == null:
			if interact_ray.is_colliding():
				var collider = interact_ray.get_collider()
				if collider.is_in_group("grabbable"):
					add_collision_exception_with(collider)
					left_grabbed_obj = collider
		elif left_grabbed_obj != null:
			remove_collision_exception_with(left_grabbed_obj)
			left_grabbed_obj = null
#right hand
	if Input.is_action_just_pressed("G"):
		if right_grabbed_obj == null:
			if interact_ray.is_colliding():
				var collider = interact_ray.get_collider()
				add_collision_exception_with(collider)
				right_grabbed_obj = collider
		elif right_grabbed_obj != null:
			remove_collision_exception_with(right_grabbed_obj)
			right_grabbed_obj = null

#sit
	if Input.is_action_just_pressed("E"):
		#sit
		if !interact_ray.is_colliding():
			return
		var collider = interact_ray.get_collider()
		if is_piloting == false:
			if collider.is_in_group("pilot_seat"):
				_pilot_airship(collider)
		else:
			_pilot_airship(self.get_parent())
		
		for group in collider.get_groups():
			match group:
				"buy_package":
					if collider.has_method("_buy_package"):
						collider._buy_package(self)
				"sell_package":
					if collider.has_method("_sell_package"):
						collider._sell_package()
				"shop":
					if collider.has_method("_opened_shop"):
						collider._opened_shop(self)

func _physics_process(delta: float) -> void:
	#wont run if the player is piloting an airship or if they are seating
	if is_piloting == true or is_seating == true:
		return
	if left_grabbed_obj != null:
		left_grabbed_obj.linear_velocity = (left_hand.global_position - left_grabbed_obj.global_position) * 20
		left_grabbed_obj.global_rotation = left_hand.global_rotation
	if right_grabbed_obj != null:
		right_grabbed_obj.linear_velocity = (right_hand.global_position - right_grabbed_obj.global_position) * 200
		right_grabbed_obj.global_rotation = right_hand.global_rotation
		
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

#pilot airship and seating function. It only allows a single player to pilot the airshipor sit as of my 
#current knowledge as I still need to add multiplayer unfortunately
func _pilot_airship(target_airship):
	if is_piloting == false:
		if target_airship.get_meta("being_piloted") == true:
			return
		is_piloting = true
		collision_shape.disabled = true
		global_transform = target_airship.global_transform
		reparent(target_airship)
		target_airship.get_parent().player_driving = self
		
	elif is_piloting == true:
		is_piloting = false
		collision_shape.disabled = false
		target_airship.get_parent().player_driving = null
		reparent(get_tree().root)
		var current_y = global_rotation.y
		global_rotation = Vector3(0, current_y, 0)
func _sit(target_seat):
	pass

func _set_wallet(new_value):
	if wallet != new_value:
		wallet = new_value
		SignalBus.update_wallet.emit(wallet)
