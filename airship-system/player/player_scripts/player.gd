extends CharacterBody3D

#camera movement variables
@onready var neck: Node3D = %neck
@onready var player_camera: Camera3D = %player_camera
var SENSITIVITY := 0.01

#grabbing system variables
var left_grabbed_obj: RigidBody3D = null
var right_grabbed_obj: RigidBody3D = null
@onready var right_hand: Marker3D = %right_hand
@onready var left_hand: Marker3D = %left_hand

#interaction variables
@onready var interact_ray: RayCast3D = %interact_ray

@onready var collision_shape: CollisionShape3D = %player_collision

#movement variables
const SPEED := 5.0
const JUMP_VELOCITY = 5
var camera_enabled: bool = true
const ACCELERATION = 10.0
const DECELERATION := 8.0

# money

#gear
var is_hooked: bool = false
var player_attachment: RigidBody3D

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
			if PlayerData.can_freely_move_cam:
				rotate_y(-event.relative.x * SENSITIVITY)
			else:
				neck.rotate_y(-event.relative.x * SENSITIVITY)
				neck.rotation.y =clamp(neck.rotation.y, deg_to_rad(-90), deg_to_rad(90))
			player_camera.rotate_x(-event.relative.y * SENSITIVITY)
			player_camera.rotation.x =clamp(player_camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

	#left hand
	if Input.is_action_just_pressed("grab_left"):
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
	if Input.is_action_just_pressed("grab_right"):
		if right_grabbed_obj == null:
			if interact_ray.is_colliding():
				var collider = interact_ray.get_collider()
				if collider.is_in_group("grabbable"):
					add_collision_exception_with(collider)
					right_grabbed_obj = collider
		elif right_grabbed_obj != null:
			remove_collision_exception_with(right_grabbed_obj)
			right_grabbed_obj = null

	if Input.is_action_just_pressed("interact"):
		var collider = null
		if interact_ray.is_colliding():
			collider = interact_ray.get_collider()

		#sit / leave seat logic
		var target_airship = null
		
		if PlayerData.is_piloting == true:
			target_airship = self.get_parent() 
		elif collider and interact_ray.is_colliding() and PlayerData.is_piloting == false:
			if collider.is_in_group("pilot_seat"):
				target_airship = collider.get_parent()
				
		# FIX: Only execute piloting if we found a valid ship node, don't completely cancel out of the function
		if target_airship != null:
			if target_airship.has_method("_pilot_airship"):
				target_airship._pilot_airship(target_airship, self)
				return # Exit here since the player just changed piloting states
			else:
				print("Error: Target missing _pilot_airship method! Found: ", target_airship.name)

		# FIX: Safety check to make sure the loop only runs if a physical item was actually hit
		if collider != null:
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
	if PlayerData.can_move == false:
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
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = lerpf(velocity.x, direction.x * SPEED, ACCELERATION * delta)
		velocity.z = lerpf(velocity.z, direction.z * SPEED, ACCELERATION * delta)
	else:
		if !is_hooked:
			velocity.x = move_toward(velocity.x, 0, DECELERATION * SPEED)
			velocity.z = move_toward(velocity.z, 0, DECELERATION * SPEED)

	move_and_slide()

func _sit(target_seat):
	pass

func _mouse_mode_manager(new_value):
	if is_shop_open != new_value:
		is_shop_open = new_value
		match is_shop_open:
			true:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			false:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
