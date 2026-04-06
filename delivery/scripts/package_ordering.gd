extends StaticBody3D

@export var package_spawn_pos: Marker3D
var package_sold = preload("res://delivery/scenes/test_package.tscn")

func _buy_package(player: CharacterBody3D):
	var package_instance: RigidBody3D = package_sold.instantiate()
	if player.wallet >= package_instance.base_price:
		get_tree().current_scene.add_child(package_instance)
		package_instance.mass = package_instance.weight
		package_instance.global_position = package_spawn_pos.global_position
		player.wallet -= package_instance.base_price
		package_instance.current_owner = player
