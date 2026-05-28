extends Projectile

var marker: Marker3D
var target: Vector3
var target_dir: Vector3
var is_active: bool = false
@export var rope_scene: PackedScene
var rope: Node3D

func _on_firing():
	if is_active:
		_delete()
	rope = rope_scene.instantiate()
	add_child(rope)
	rope.top_level = true

func _on_collision(body: Node) -> void:
	is_active = false
	player.is_hooked = false
	
	#makes sure other code has ran before freezing (prevents from freezing in the air)
	set_deferred("freeze", true)
	
	marker = Marker3D.new()
	body.add_child(marker)
	marker.global_position = self.global_position
	
	is_active = true
	player.is_hooked = true

func _physics_process(delta: float) -> void:
	if marker != null:
		self.global_position = marker.global_position
		target = global_position
		target_dir = player.global_position.direction_to(target)
	var distance = gun.origin.global_position.distance_to(self.global_position)
	rope.global_position = gun.origin.global_position
	if distance > 0.01:
		rope.look_at(self.global_position)
	rope.scale = Vector3(1, 1, distance/2.0)
	if distance > 200:
		_delete()

	if is_active:
		var target_dist = player.global_position.distance_to(target)
		player.velocity = target_dir * 20.0
		
		player.move_and_slide()
		
		if target_dist <= 2.0:
			call_deferred("_delete")

func _delete():
	is_active = false
	player.is_hooked = false
	rope.queue_free()
	queue_free()
