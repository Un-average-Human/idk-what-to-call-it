extends Node3D

@export var ray: RayCast3D
@export var player: CharacterBody3D
var target: Vector3
var distance
var is_swinging: bool = false
var is_pulling: bool = false
var player_attachment: RigidBody3D
var current_joint: PinJoint3D
var current_anchor: StaticBody3D

func _ready() -> void:
	set_physics_process(false)

func _input(event: InputEvent) -> void:
#pull
	if Input.is_action_just_pressed("LMB"):
		if ray.is_colliding() and is_pulling == false and is_swinging == false:
			target = ray.get_collision_point()
			distance = player.global_position.distance_to(target)
			if distance > 3:
				set_physics_process(true)
				is_pulling = true
				player.is_hooked = true

#swing
	if Input.is_action_just_pressed("RMB") and player.is_hooked == false:
		if ray.is_colliding():
			target = ray.get_collision_point()
			distance = player.global_position.distance_to(target)
			if distance > 3:
				player.is_swinging = true
				set_physics_process(true)
				_swing()
	if Input.is_action_just_released("RMB"):
		if current_joint:
			current_joint.queue_free()
		if current_anchor:
			current_anchor.queue_free()
		if player_attachment:
			player.velocity = player_attachment.linear_velocity
			player_attachment.queue_free()
		is_swinging = false

func _physics_process(delta: float) -> void:
	distance = player.global_position.distance_to(target)
	if is_pulling:
		if distance < 1.5:
			player.is_hooked = false
			set_physics_process(false)
			is_pulling = false
			return
		_pull(delta)
	if is_swinging == true:
		if player_attachment != null:
			player.global_position = player_attachment.global_position
			player.velocity = player_attachment.linear_velocity
			var height_diff = target.y - player.global_position.y
			if height_diff < 1.5 and player_attachment.linear_velocity.y > 0:
				player_attachment.linear_damp = 1.0
			else:
				player_attachment.linear_damp = 0.0

func _pull(delta: float):
	var direction = player.global_position.direction_to(target)
	player.velocity = direction * 20.0

func _swing():
	if is_swinging == false:
		is_swinging = true
		var root = get_tree().root
		
		current_joint = PinJoint3D.new()
		root.add_child(current_joint)
		
		current_anchor = StaticBody3D.new()
		root.add_child(current_anchor)
		current_anchor.global_position = target
		
		player_attachment = RigidBody3D.new()
		root.add_child(player_attachment)
		player_attachment.can_sleep = false
		player_attachment.mass = 62
		
		player_attachment.global_position = player.global_position
		player.player_attachment = player_attachment
		player_attachment.linear_velocity = player.velocity
		
		current_joint.global_position = target
		
		current_joint.node_a = current_anchor.get_path()
		current_joint.node_b = player_attachment.get_path()
