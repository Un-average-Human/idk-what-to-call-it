extends Node

@export var player: CharacterBody3D
@export var projectile_scene: PackedScene
@export var ray: RayCast3D
@export var origin: Marker3D
var projectile_instance
var target_point
var target_dir
var test: Array
var can_shoot: bool = true
@export var launch_speed = 30.0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("LMB"):
		if is_instance_valid(projectile_instance):
			projectile_instance.queue_free()
		elif can_shoot:
			_shoot()

func _shoot():
	
	can_shoot = false
	
	if is_instance_valid(projectile_instance):
		projectile_instance.queue_free()
	
	projectile_instance = projectile_scene.instantiate()
	get_tree().root.add_child(projectile_instance)
	projectile_instance.add_collision_exception_with(player)
	projectile_instance.gun = self
	projectile_instance._on_firing()
	projectile_instance.player = player
	projectile_instance.global_position = origin.global_position
	
	
	if ray.is_colliding():
		target_point = ray.get_collision_point()
		projectile_instance.look_at(target_point)
	else:
		target_point = ray.to_global(ray.target_position)
		projectile_instance.look_at(target_point)
	
	target_dir = projectile_instance.global_position.direction_to(target_point)
	projectile_instance.linear_velocity = target_dir * projectile_instance.speed
	
	await get_tree().create_timer(projectile_instance.cooldown).timeout
	can_shoot = true
