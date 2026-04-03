extends RigidBody3D

var is_grabbed: bool = false
var hand_used: Marker3D
@export var collision: CollisionShape3D

func _ready() -> void:
	set_physics_process(false)

func _grab():
	if is_grabbed == false:
		collision.disabled = true
		freeze = true
		set_physics_process(true)
		is_grabbed = true
func _drop():
	if is_grabbed == true:
		is_grabbed = false
		set_physics_process(false)
		collision.disabled = false
		freeze = false

func _physics_process(delta: float) -> void:
	self.global_transform = lerp(global_transform, hand_used.global_transform, delta * 10)
