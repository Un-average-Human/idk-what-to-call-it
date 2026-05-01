extends Area3D

var distance_to_center
@export var spin_speed: float
@export var radius: float

func _physics_process(delta: float) -> void:
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body is RigidBody3D:
			distance_to_center = global_position - body.global_position
			distance_to_center.y = 0
			var strength = clamp(1.0 - (distance_to_center.length() / radius), 0.0, 1.0)
			var spin_dir = Vector3.UP.cross(distance_to_center.normalized())
			
			body.apply_central_force(spin_dir * spin_speed * strength)
