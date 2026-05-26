extends Projectile

#static makes it available for every object in this class (Projectile)
static var point_a: Vector3 = Vector3.INF
var point_b: Vector3 = Vector3.INF
var is_second_bullet: bool = false
var origin_point: Vector3
static var bullets: Array[Node3D]

@export var zipline_scene: PackedScene
static var zipline
@export var rope_scene: PackedScene
var rope
static var current_rope

var is_active: bool = false
var distance

func _on_firing():
	if bullets.size() >= 2:
		for bullet in bullets:
			if is_instance_valid(bullet):
				bullet._delete()
		if is_instance_valid(zipline):
			zipline._delete()
		bullets.clear()
		point_a = Vector3.INF
		current_rope = null
		_delete()
		return
	if bullets.size() == 1:
		if point_a == Vector3.INF:
			bullets[0].queue_free()
			bullets.clear()
			_delete()
			return

	if point_a != Vector3.INF:
		is_second_bullet = true
		rope = current_rope

	else:
		rope = rope_scene.instantiate()
		add_child(rope)
		rope.top_level = true
		current_rope = rope

	bullets.append(self)

func _on_collision(body: Node) -> void:
	#makes sure other code has ran before freezing (prevents from freezing in the air)
	set_deferred("freeze", true)
	if point_a == Vector3.INF:
		point_a = global_position
	else:
		point_b = global_position
		_create_zipline()

func _physics_process(_delta: float) -> void:
	if not is_instance_valid(rope):
		return
		
	if point_b == Vector3.INF:
		if is_second_bullet:
			origin_point = point_a 
		else:
			origin_point = gun.origin.global_position
		distance = origin_point.distance_to(global_position)
		rope.global_position = origin_point

		if distance > 0.01:
			rope.look_at(global_position)
		rope.scale = Vector3(1, 1, distance / 2.0)
		if distance > 150:
			_delete()

	else:
		rope.global_position = point_a
		rope.look_at(point_b)
		rope.scale = Vector3(1, 1, point_a.distance_to(point_b) / 2.0)

func _create_zipline():
	zipline = zipline_scene.instantiate()
	get_tree().current_scene.add_child(zipline)
	var path_follow = zipline.find_child("PathFollow")
	zipline.curve = Curve3D.new()
	#first point
	zipline.curve.add_point(point_a)
	#second point
	zipline.curve.add_point(point_b)
	zipline._zipline_created()
	

func _delete():
	set_physics_process(false)
	queue_free()
