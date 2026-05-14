extends PathFollow3D

var riding_player: CharacterBody3D
var parent_path: Path3D

var zipline_direction: float = 1.0
var rope_angle: float
var is_below: bool
var is_sliding: bool
var player_speed: float

func start_riding(player: CharacterBody3D, path_node: Path3D, initial_progress: float) -> void:
	riding_player = player
	parent_path = path_node
	progress = initial_progress
	
	calculate_zipline_direction(riding_player)
	is_player_underneath(riding_player)
	
	if zipline_direction < 0:
		progress_ratio -= 0.05
	if zipline_direction > 0:
		progress_ratio += 0.05

func calculate_zipline_direction(player: CharacterBody3D) -> void:
	var curve = parent_path.get_curve()
	var path_length: float = curve.get_baked_length()
	
	var start_pos: Vector3 = parent_path.to_global(curve.sample_baked(0.0))
	var end_pos: Vector3 = parent_path.to_global(curve.sample_baked(path_length))
	
	var rope_dir: Vector3 = (end_pos - start_pos).normalized()
	var player_dir = -player.global_transform.basis.z
	
	var dot: float = player_dir.dot(rope_dir)
	
	var target_rotation: Vector3
	
	if dot >= 0.0:
		zipline_direction = 1.0
		target_rotation = parent_path.to_global(curve.sample_baked(path_length))
	else:
		zipline_direction = -1.0
		target_rotation = parent_path.to_global(curve.sample_baked(0.0))
	
	target_rotation.y = player.global_position.y
	player.can_freely_move_cam = false
	
	var target_transform = player.global_transform.looking_at(target_rotation, Vector3.UP)
	var target_quat = target_transform.basis.get_rotation_quaternion()
	
	var tween: Tween = create_tween()
	tween.tween_property(player, "quaternion", target_quat, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)

func is_player_underneath(player: CharacterBody3D) -> void:
	var curve = parent_path.get_curve()
	var closest_offset = curve.get_closest_offset(parent_path.to_local(player.global_position))
	var rope_global_pos = parent_path.to_global(curve.sample_baked(closest_offset))
	
	var rope_to_player: Vector3 = player.global_position - rope_global_pos
	
	var vertical_dot = rope_to_player.normalized().dot(Vector3.UP)
	is_below = vertical_dot < -0.1
	
	rope_angle = rotation_degrees.x * -zipline_direction
	if rope_angle >= 1:
		is_sliding = true

func _physics_process(delta: float) -> void:
	if is_instance_valid(riding_player):
		if is_below:
			riding_player.global_position = global_position - Vector3(0, 1, 0)
			if is_sliding:
				player_speed = move_toward(player_speed, 25.0, 5.0 * delta)
			else:
				player_speed = 3.0
		else:
			riding_player.global_position = global_position + Vector3(0, 1, 0)
			if is_sliding:
				player_speed = move_toward(player_speed, 25.0, 5.0 * delta)
			else:
				player_speed = 4.0
			
		var input = Input.get_axis("S", "W")
		
		if is_sliding:
			input = 1.0
		
		progress += (player_speed * zipline_direction * input) * delta
			
		if progress_ratio > 0.99 or progress_ratio < 0.01:
			if parent_path:
				parent_path.call("_on_player_stop_ziplining", riding_player)
