extends Path3D

@export var temp_zipline_collision: CollisionPolygon3D
@export var zipline_area: Area3D
@export var path_follow: PathFollow3D
@export_range(0.01, 2.0) var rope_thickness: float = 0.1

var zipline_direction: float = 1.0
var player: CharacterBody3D = null

func _zipline_created():
	#creates da collision shape that will be baked
	temp_zipline_collision.polygon = PackedVector2Array([
		Vector2(-rope_thickness, -rope_thickness),
		Vector2(rope_thickness, -rope_thickness),
		Vector2(rope_thickness, rope_thickness),
		Vector2(-rope_thickness, rope_thickness)
	])
	
	var path_length = get_curve().get_baked_length()
	temp_zipline_collision.depth  = path_length
	temp_zipline_collision.position = curve.get_point_position(0)
	
	#aangles it properly
	var end_point = curve.get_point_position(curve.point_count - 1)
	temp_zipline_collision.look_at(end_point)
	
	temp_zipline_collision.position = curve.sample_baked(path_length / 2.0)

func _delete():
	if temp_zipline_collision:
		temp_zipline_collision.queue_free()
	path_follow.queue_free()
	queue_free()

func _physics_process(delta: float) -> void:
	if player:
		var input = Input.get_axis("S", "W")
		path_follow.progress += (5.0 * zipline_direction * input) * delta
			
		player.global_position = path_follow.global_position

func _on_player_ziplining(body: Node3D) -> void:
	if !body.is_in_group("player"):
		return
		
	player = body
	body.can_move = false
	
	var player_pos = to_local(body.global_position) + Vector3(0, -2, 0)
	var closest_point = get_curve().get_closest_offset(player_pos)
	path_follow.progress = closest_point
	
	calculate_zipline_direction()

func calculate_zipline_direction() -> void:
	var path_length: float = curve.get_baked_length()
	
	var start_pos: Vector3 = to_global(curve.sample_baked(0.0))
	var end_pos: Vector3 = to_global(curve.sample_baked(path_length))
	
	var rope_dir: Vector3 = (end_pos - start_pos).normalized()
	
	var camera_node = player.get_node_or_null("Camera3D")
	var target_transform = camera_node.global_transform if camera_node else player.global_transform
	var camera_dir: Vector3 = -target_transform.basis.z 
	
	var dot: float = camera_dir.dot(rope_dir)
	
	var target_rotation: Vector3
	
	if dot >= 0.0:
		zipline_direction = 1.0
		target_rotation = to_global(curve.sample_baked(path_length))
	else:
		zipline_direction = -1.0
		target_rotation = to_global(curve.sample_baked(0.0))
	
	target_rotation.y = player.global_position.y
	player.can_freely_move_cam = false
	player.look_at(target_rotation, Vector3.UP)
