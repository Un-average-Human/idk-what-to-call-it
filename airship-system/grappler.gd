extends Node

@export var grapple_ray: RayCast3D
@export var player: CharacterBody3D

const REST_LENGTH: float = 0.1
const STIFFNESS: float = 8.0
const DAMPING: float = 4.0

var grappler_target: Vector3
var launched: bool = false: set = _set_launched

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("LMB"):
		_launch_grappler()
	if Input.is_action_just_released("LMB"):
		_retract_grappler()

func _launch_grappler():
	if grapple_ray.is_colliding():
		grappler_target = grapple_ray.get_collision_point()
		launched = true

func _retract_grappler():
	launched = false

func _handle_grappler(delta: float):
	var target_dir = player.global_position.direction_to(grappler_target)
	var target_dist = player.global_position.distance_to(grappler_target)
	
	var displacement = target_dist - REST_LENGTH
	
	var force = Vector3.ZERO
	
	if displacement > 0:
		var spring_force_magnitude = STIFFNESS * displacement
		var spring_force = target_dir * spring_force_magnitude
		
		var vel_dot = player.velocity.dot(target_dir)
		var damping = -DAMPING * vel_dot * target_dir
		
		force = spring_force + damping
	
	player.velocity += force * delta

func _set_launched(new_value):
	if launched != new_value:
		launched = new_value
		if launched == true:
			set_physics_process(true)
		else:
			set_physics_process(false)

func _physics_process(delta: float) -> void:
	_handle_grappler(delta)
