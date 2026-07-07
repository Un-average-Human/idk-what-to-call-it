extends Path3D

@export var temp_zipline_collision: CollisionPolygon3D
@export var zipline_area: Area3D
@export_range(0.01, 2.0) var rope_thickness: float = 0.1

var zipline_direction: float = 1.0
var is_below: bool
var is_angled: bool
var angle_threshold: float

var active_players: Array[CharacterBody3D] = []
var players_inside_zone: Array[CharacterBody3D] = []
var player_speed: float

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		for target_player in players_inside_zone:
			_on_player_ziplining(target_player)
			break
	if event.is_action_pressed("jump"):
		for riding_player in active_players.duplicate():
			if is_instance_valid(riding_player):
				_on_player_stop_ziplining(riding_player)

func _zipline_created() -> void:
	if temp_zipline_collision == null:
		return
	temp_zipline_collision.polygon = PackedVector2Array([
		Vector2(-rope_thickness, -rope_thickness),
		Vector2(rope_thickness, -rope_thickness),
		Vector2(rope_thickness, rope_thickness),
		Vector2(-rope_thickness, rope_thickness)
	])
	
	var path_length = get_curve().get_baked_length()
	temp_zipline_collision.depth  = path_length
	temp_zipline_collision.position = curve.get_point_position(0)
	var end_point = curve.get_point_position(curve.point_count - 1)
	temp_zipline_collision.look_at(end_point)
	
	temp_zipline_collision.position = curve.sample_baked(path_length / 2.0)

func _player_in_range(body: Node3D) -> void:
	if body.is_in_group("player") and body is CharacterBody3D:
		if !players_inside_zone.has(body) and !active_players.has(body):
			players_inside_zone.append(body)

func _player_left_range(body: Node3D) -> void:
	if body is CharacterBody3D:
		players_inside_zone.erase(body)

func _on_player_ziplining(body: Node3D) -> void:
	if active_players.has(body):
		return
	
	active_players.append(body)
	players_inside_zone.erase(body)
	
	PlayerData.can_move = false
	
	#creates a pathfollwo for da player
	var rider_follow = PathFollow3D.new()
	var shape_cast = ShapeCast3D.new()
	shape_cast.set_shape(CapsuleShape3D.new())
	rider_follow.set_script(preload("uid://dekkm6a6ovlbc"))
	add_child(rider_follow)
	rider_follow.add_child(shape_cast)
	
	var player_pos = to_local(body.global_position) + Vector3(0, -2, 0)
	var closest_point = get_curve().get_closest_offset(player_pos)
	
	rider_follow._start_riding(body, self, closest_point)

func _on_player_stop_ziplining(body) -> void:
	if active_players.has(body):
		active_players.erase(body)
		PlayerData.can_move = true
		PlayerData.can_freely_move_cam = true
		
		for child in get_children():
			if child is PathFollow3D and child.get("riding_player") == body:
				child.queue_free()
				
		var tween: Tween = create_tween()
		tween.tween_property(body.neck, "rotation", Vector3.ZERO, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)

func _delete():
	if temp_zipline_collision:
		temp_zipline_collision.queue_free()
		for riding_player in active_players.duplicate():
			if is_instance_valid(riding_player):
				_on_player_stop_ziplining(riding_player)
	queue_free()
