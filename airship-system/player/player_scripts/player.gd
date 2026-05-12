extends CharacterBody3D

#camera movement variables
@onready var neck: Node3D = $neck
@onready var player_camera: Camera3D = $neck/player_camera
var SENSITIVITY := 0.01
var can_freely_move_cam: bool = true

#grabbing system variables
var left_grabbed_obj: RigidBody3D = null
var right_grabbed_obj: RigidBody3D = null
@onready var right_hand: Marker3D = $neck/player_camera/right_hand
@onready var left_hand: Marker3D = $neck/player_camera/left_hand

#interaction variables
@onready var interact_ray: RayCast3D = $neck/player_camera/interact_ray

#pilot and seat variables
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
var can_move := true
var is_piloting := false
var is_seating := false

#movement variables
const SPEED := 5.0
const JUMP_VELOCITY = 5
var camera_enabled: bool = true
const ACCELERATION = 10.0
const DECELERATION := 8.0

# money
var wallet: float = 500.0: set = _set_wallet

#airships
var owned_airships: Array[AirshipData]
var airship_spawned: RigidBody3D

#gear
var is_hooked: bool = false
var player_attachment: RigidBody3D
var owned_gear: Array

#shop
var is_shop_open: bool = false: set = _mouse_mode_manager

#main functions
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	#lock mouse
	if Input.is_action_just_pressed("ui_cancel") and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif Input.is_action_just_pressed("ui_cancel") and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

#camera
	if event is InputEventMouseMotion and camera_enabled == true:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			if can_freely_move_cam:
				rotate_y(-event.relative.x * SENSITIVITY)
			else:
				neck.rotate_y(-event.relative.x * SENSITIVITY)
				neck.rotation.y =clamp(neck.rotation.y, deg_to_rad(-90), deg_to_rad(90))
			player_camera.rotate_x(-event.relative.y * SENSITIVITY)
			player_camera.rotation.x =clamp(player_camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

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
				if collider.is_in_group("grabbable"):
					add_collision_exception_with(collider)
					right_grabbed_obj = collider
		elif right_grabbed_obj != null:
			remove_collision_exception_with(right_grabbed_obj)
			right_grabbed_obj = null



	if Input.is_action_just_pressed("E"):
		#sit
		if is_piloting == true:
			_pilot_airship(self.get_parent())
			return
		if !interact_ray.is_colliding():
			return
		var collider = interact_ray.get_collider()
		if is_piloting == false:
			if collider.is_in_group("pilot_seat"):
				_pilot_airship(collider)
		
		for group in collider.get_groups():
			match group:
				"buy_package":
					if collider.has_method("_buy_package"):
						collider._buy_package(self)
				"sell_package":
					if collider.has_method("_sell_package"):
						collider._sell_package()
				"shop":
					if collider.has_method("_opened_shop") and !is_shop_open:
						is_shop_open = true
						
						camera_enabled = false
						collider._opened_shop(self)

func _physics_process(delta: float) -> void:
	#wont run if the player is piloting an airship or if they are seating
	if can_move == false:
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
		velocity.x = lerpf(velocity.x, direction.x * SPEED, ACCELERATION * delta)
		velocity.z = lerpf(velocity.z, direction.z * SPEED, ACCELERATION * delta)
	else:
		if !is_hooked:
			velocity.x = move_toward(velocity.x, 0, DECELERATION * SPEED)
			velocity.z = move_toward(velocity.z, 0, DECELERATION * SPEED)

	move_and_slide()

#pilot airship and seating function. It only allows a single player to pilot the airshipor sit as of my 
#current knowledge as I still need to add multiplayer unfortunately
func _pilot_airship(target_airship):
	if is_piloting == false:
		is_piloting = true
		can_move = false
		collision_shape.disabled = true
		global_transform = target_airship.global_transform
		reparent(target_airship)
		target_airship.get_parent().player_driving = self
		target_airship.get_parent().get_node("camera_arm").get_child(0).make_current()
		
	elif is_piloting == true:
		is_piloting = false
		can_move = true
		collision_shape.disabled = false
		target_airship.get_parent().player_driving = null
		reparent(get_tree().root)
		var current_y = global_rotation.y
		global_rotation = Vector3(0, current_y, 0)
		player_camera.make_current()
func _sit(target_seat):
	pass

func _set_wallet(new_value):
	if wallet != new_value:
		wallet = new_value
		SignalBus.update_wallet.emit(wallet)
func _mouse_mode_manager(new_value):
	if is_shop_open != new_value:
		is_shop_open = new_value
		match is_shop_open:
			true:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			false:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
