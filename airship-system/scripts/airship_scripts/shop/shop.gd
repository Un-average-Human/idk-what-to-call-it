extends StaticBody3D
var shipwright_popup_scene = preload("uid://dwonluj7neod2")

@export var shipwright: ShipwrightData

var docks: Array[Marker3D] = []

func _ready() -> void:
	for dock in self.get_children():
		if dock is Marker3D:
			shipwright.docks.append(dock)

func _opened_shop(player: CharacterBody3D):
	var shipwright_popup = shipwright_popup_scene.instantiate()
	shipwright_popup.player = player
	shipwright_popup.airship_data = shipwright.airships_available
	shipwright_popup.shipwright_name = shipwright.shipwright_name
	shipwright_popup.docks = shipwright.docks
	player.add_child(shipwright_popup)
