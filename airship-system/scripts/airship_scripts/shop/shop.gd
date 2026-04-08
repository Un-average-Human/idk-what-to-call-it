extends StaticBody3D
var shipwright_popup_scene = preload("uid://dwonluj7neod2")

@export var airships: Array[AirshipData]

func _opened_shop(player: CharacterBody3D):
	var shipwright_popup = shipwright_popup_scene.instantiate()
	shipwright_popup.player = player
	shipwright_popup.airship_data = airships
	player.add_child(shipwright_popup)
