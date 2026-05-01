extends RigidBody3D

@export var airship: AirshipStats
var direction := 0
var steering_input := 0

@export var helm :Node3D
@export var rudder: Node3D
@export var propellers: Array[Node3D]
@export var propeller_rotating_speed: float

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

func _input(event: InputEvent) -> void:
	if player_driving == null:
		return
	if !is_preview:
		if Input.is_action_just_pressed("W") and current_speed < airship.max_speed:
			current_speed += airship.speed_increment
		if Input.is_action_just_pressed("S") and current_speed > -airship.max_speed:
			current_speed -= airship.speed_increment
		if Input.is_action_just_pressed("Q") and current_lift < airship.max_lift:
			current_lift += airship.lift_increment
		if Input.is_action_just_pressed("Z") and current_lift > airship.min_lift:
			current_lift -= airship.lift_increment
		if Input.is_action_just_pressed("X"):
			current_speed = 0

func _physics_process(delta: float) -> void:
	var target_tilt_rad = deg_to_rad(steering_input * airship.tilt_angle)
	var angle_difference = target_tilt_rad - global_rotation.z
	
	var spring_stiffness = 20.0 
	var spring_damping = 06.0
	
	var torque_z = (angle_difference * spring_stiffness) - (angular_velocity.z * spring_damping)
	
	
	#making the camera arm follow the airship
	if !is_preview:
		camera_arm.global_position = lerp(camera_arm.global_position, global_position, delta * 6)
	
#boring steering stuff
	if player_driving != null and is_preview == false:
		steering_input = Input.get_axis("D","A")
	else:
		steering_input = 0
	if current_speed >= 0:
		direction = 1
	elif current_speed < 0:
		direction = -1

#turning and tilting functions
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
	rudder.rotation.y = lerp_angle(rudder.rotation.y, deg_to_rad(steering_input * -airship.rudder_max_rotation), delta * 5)
	helm.rotation.y = lerp(helm.rotation.y, deg_to_rad(direction * steering_input * airship.helm_max_rotation), delta * 5)
#lift
	apply_central_force(Vector3(0, current_lift, 0))
#forward and backward movement
	apply_central_force(-global_transform.basis.z * current_speed * mass)
	apply_central_force(-linear_velocity * mass * 0.5)
