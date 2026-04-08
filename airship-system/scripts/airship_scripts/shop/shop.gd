extends StaticBody3D

var shop_ui = preload("uid://tbspm3kva16q").instantiate()
@export var airships: Array[AirshipData]

func _open_shop(player: CharacterBody3D):
	print("function called")
	shop_ui.player = player
	shop_ui.airships = airships
	player.add_child(shop_ui)
