extends StaticBody3D

@export var package_spawn_pos: Marker3D
var package_sold = preload("res://scenes/delivery_scenes/packages/test_package.tscn")

func _buy_package(player: CharacterBody3D):
	var package_instance: RigidBody3D = package_sold.instantiate()
	#checks if the player has enough money
	if player.wallet >= package_instance.base_price:
		#adds the package to the scene and positions it
		get_tree().current_scene.add_child(package_instance)
		package_instance.global_position = package_spawn_pos.global_position
		#set the player as the owner and subtracts the box price from the player's money
		player.wallet -= package_instance.base_price
		package_instance.current_owner = player
