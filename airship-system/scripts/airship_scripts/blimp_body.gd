extends RigidBody3D

var direction := 0
var steering_input := 0

@export var helm :Node3D
@export var rudder: Node3D
@export var helm_max_rotation: float = 120
@export var rudder_max_rotation: float = 90

@export var propellers: Array[Node3D]
@export var propeller_rotating_speed: float

@export var turn_power: float
@export var tilt_angle: float

@export var min_lift: float
@export var max_lift: float
var current_lift: float
@export var lift_increment: float

var current_speed := 0.0
@export var max_speed: float
@export var speed_increment: float

var player_driving: CharacterBody3D
@export var camera_arm: SpringArm3D
@export var max_zoom_out: int
@export var max_zoom_in: int
var is_preview: bool = false

func _ready() -> void:
	camera_arm.top_level = true
	current_lift = min_lift

func _input(event: InputEvent) -> void:
	if player_driving == null:
		return
	if !is_preview:
		if Input.is_action_just_pressed("W") and current_speed < max_speed:
			current_speed += speed_increment
		if Input.is_action_just_pressed("S") and current_speed > -max_speed:
			current_speed -= speed_increment
		if Input.is_action_just_pressed("Q") and current_lift < max_lift:
			current_lift += lift_increment
		if Input.is_action_just_pressed("Z") and current_lift > min_lift:
			current_lift -= lift_increment
		if Input.is_action_just_pressed("X"):
			current_speed = 0
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		camera_arm.add_excluded_object(self)
		var sens = player_driving.SENSITIVITY
		camera_arm.rotation.y -= event.relative.x * sens
		
		camera_arm.rotation.x -= event.relative.y * sens
		camera_arm.rotation.x = clamp(camera_arm.rotation.x, -PI/2, PI/4)
	
	if Input.is_action_just_pressed("WheelUp") and camera_arm.spring_length > max_zoom_in:
		camera_arm.spring_length -= 1
	elif Input.is_action_just_pressed("WheelDown") and camera_arm.spring_length < max_zoom_out:
		camera_arm.spring_length += 1

func _physics_process(delta: float) -> void:
	
	#making the camera arm follow the airship
	camera_arm.global_position = lerp(camera_arm.global_position, global_position, delta * 6)
	
#boring steering stuff
	if player_driving != null and is_preview == false:
		steering_input = Input.get_action_strength("A") - Input.get_action_strength("D")
	else:
		steering_input = 0
	if current_speed >= 0:
		direction = 1
	elif current_speed < 0:
		direction = -1

#turning and tilting functions. Ill leave the tilt as it is cuz this shit is irritating me
	if steering_input != null and current_speed != 0:
		global_rotation.z = lerp_angle(global_rotation.z, deg_to_rad(steering_input * tilt_angle), 0.75 * delta)
		angular_velocity.y = lerpf(angular_velocity.y, steering_input, smoothstep(0, 1, delta * turn_power))
	global_rotation.x = 0.0
	angular_velocity.z = 0.0
	global_rotation.z = lerp_angle(global_rotation.z, 0.0, delta)
	
#propellers
	if current_speed != 0:
		for propeller in propellers:
			propeller.rotate_z(propeller_rotating_speed * current_speed * delta)
	rudder.rotation.y = lerp_angle(rudder.rotation.y, deg_to_rad(direction * steering_input * -rudder_max_rotation), delta * 5)
	helm.rotation.y = lerp(helm.rotation.y, deg_to_rad(direction * steering_input * helm_max_rotation), delta * 5)
	#forward direction is negative for sum reason, thats why im using "less than". Stupid engine frfr
	apply_central_force(Vector3(0, current_lift, 0))
	linear_velocity = linear_velocity.lerp(global_transform.basis.z * -current_speed, speed_increment)
	
