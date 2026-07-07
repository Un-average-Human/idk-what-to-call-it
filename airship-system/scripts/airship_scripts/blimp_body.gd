extends RigidBody3D

@export var airship: AirshipStats
var direction := 0
var steering_input := 0

@export var helm :Node3D
@export var rudder: Node3D
@export var propellers: Array[Node3D]
@export var propeller_rotating_speed: float

# NEW: Drag your pilot seat mesh or a Marker3D node into this slot in the inspector
@export var pilot_seat: Node3D 

var current_lift: float

var current_speed := 0.0

var player_driving: CharacterBody3D
@export var camera_arm: SpringArm3D
var is_preview: bool = false
var in_tornado: bool = false
var tilt_factor: float = 0.0

func _ready() -> void:
	camera_arm.top_level = true
	current_lift = airship.min_lift

func _pilot_airship(target_airship, player):
	if PlayerData.is_piloting == false:
		PlayerData.is_piloting = true
		PlayerData.can_move = false
		player.collision_shape.disabled = true
		
		player.velocity = Vector3.ZERO
		Input.action_release("jump")
		
		player.reparent(self)
		
		if pilot_seat:
			player.global_transform = pilot_seat.global_transform
		else:
			player.global_position = global_position 
		
		self.player_driving = player
		
		if camera_arm and camera_arm.get_child_count() > 0:
			camera_arm.get_child(0).make_current()
		
		set_process(false)
		
	elif PlayerData.is_piloting == true:
		set_process(true)
		Input.action_release("jump")
		player.velocity = Vector3.ZERO
		
		PlayerData.is_piloting = false
		PlayerData.can_move = true
		player.collision_shape.disabled = false
		
		self.player_driving = null
		
		player.reparent(get_tree().root)
		
		if pilot_seat:
			player.global_position = pilot_seat.global_position
		
		var current_y = global_rotation.y
		global_rotation = Vector3(0, current_y, 0)
		player.player_camera.make_current()

func _input(event: InputEvent) -> void:
	if player_driving == null:
		return
	if !is_preview:
		if Input.is_action_just_pressed("increase_speed") and current_speed < airship.max_speed:
			current_speed += airship.speed_increment
		if Input.is_action_just_pressed("decrease_speed") and current_speed > -airship.max_speed:
			current_speed -= airship.speed_increment
		if Input.is_action_just_pressed("increase_hydrogen") and current_lift < airship.max_lift:
			current_lift += airship.lift_increment
		if Input.is_action_just_pressed("decrease_hydrogen") and current_lift > airship.min_lift:
			current_lift -= airship.lift_increment
		if Input.is_action_just_pressed("halt"):
			current_speed = 0

func _physics_process(delta: float) -> void:
	var target_tilt_rad = deg_to_rad(steering_input * airship.tilt_angle)
	var angle_difference = target_tilt_rad - global_rotation.z
	
	var spring_stiffness = 20.0 
	var spring_damping = 06.0
	
	var torque_z = (angle_difference * spring_stiffness) - (angular_velocity.z * spring_damping)
	
	#making the camera arm follow the airship
	if !is_preview and camera_arm:
		camera_arm.global_position = lerp(camera_arm.global_position, global_position, delta * 6)
	
	#boring steering stuff
	if player_driving != null and is_preview == false:
		steering_input = Input.get_axis("turn_right","turn_left")
	else:
		steering_input = 0
	if current_speed >= 0:
		direction = 1
	elif current_speed < 0:
		direction = -1

	#turning and tilting
	apply_torque(global_transform.basis.x * -global_rotation.x * 50 * mass)
	if current_speed == 0:
		apply_torque(global_transform.basis.z * torque_z * mass)

	if steering_input != null and current_speed != 0:
		angular_velocity.y = lerpf(angular_velocity.y, direction * steering_input, smoothstep(0, 1, delta * airship.turn_power))
		apply_torque(global_transform.basis.z * torque_z * mass)
		
	#propellers
	if current_speed != 0:
		for propeller in propellers:
			propeller.rotate_z(propeller_rotating_speed * current_speed * delta)
			
	#rudder and helm
	if rudder:
		rudder.rotation.y = lerp_angle(rudder.rotation.y, deg_to_rad(steering_input * -airship.rudder_max_rotation), delta * 5)
	if helm:
		helm.rotation.y = lerp(helm.rotation.y, deg_to_rad(direction * steering_input * airship.helm_max_rotation), delta * 5)
		
	#lift
	apply_central_force(Vector3(0, current_lift, 0))
	
	#forward and backward movement
	apply_central_force(-global_transform.basis.z * current_speed * mass)
	apply_central_force(-linear_velocity * mass * 0.5)
