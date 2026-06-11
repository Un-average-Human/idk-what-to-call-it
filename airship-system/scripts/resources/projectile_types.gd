extends RigidBody3D
class_name Projectile

@export var speed: float
@export var collision_exceptions: Array
@export var player: CharacterBody3D
@export var cooldown: float
@export var single_shot: bool
var can_shoot: bool = true

var gun: Node

func _on_firing():
	pass

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 10
	body_entered.connect(_on_collision)

func _on_collision(body: Node) -> void:
	pass
func _delete():
	pass
