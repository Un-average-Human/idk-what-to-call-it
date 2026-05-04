extends Node

@export var ray: RayCast3D

@export var rest_lentgh: float = 2.0
@export var stiffness: float = 10.0
@export var damping: float = 1.0

@export var player: CharacterBody3D

var target: Vector3
var launched: bool = false

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("LMB"):
		_launch()
	if Input.is_action_just_released("LMB"):
		_retract()
	
	if launched:
		_handle_grapple(delta)

func _launch():
	if ray.is_colliding():
		target = ray.get_collision_point()
		launched = true

func _retract():
	launched = false

func _handle_grapple(delta: float):
	var target_dir: Vector3 = player.global_position.direction_to(target)
	var target_dist: float = player.global_position.distance_to(target)
	
	var displacement: float = target_dist - rest_lentgh
	
	var force: Vector3 = Vector3.ZERO
	
	if displacement > 0:
		var spring_force_magnitude: float = stiffness * displacement
		var spring_force: Vector3 = target_dir * spring_force_magnitude
		
		var vel_dot: float = player.velocity.dot(target_dir)
		var damping = -damping * vel_dot * target_dir
		
		force = spring_force + damping
	
	player.velocity += force * delta
