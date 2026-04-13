extends CanvasLayer

@export var shop_button: Button
@export var hangar_button: Button
@export var close_button: Button
@export var shipwright_name_label: RichTextLabel

var shop_ui_scene: PackedScene = preload("uid://tbspm3kva16q")
var hangar_ui_scene: PackedScene = preload("uid://bfnh4r118aj18")
var player: CharacterBody3D
var airship_data: Array[AirshipData]

var shipwright_name: String
var docks: Array[Marker3D]

func _ready() -> void:
	shipwright_name_label.text = shipwright_name
	shop_button.pressed.connect(_open_shop)
	hangar_button.pressed.connect(_open_hangar)
	close_button.pressed.connect(_close_popup)

func _open_shop():
	var shop_ui = shop_ui_scene.instantiate()
	shop_ui.player = player
	shop_ui.airships = airship_data
	shop_ui.shipwright_popup = self
	player.add_child(shop_ui)
	self.hide()

func _open_hangar():
	var hangar_ui = hangar_ui_scene.instantiate()
	hangar_ui.player = player
	hangar_ui.airships = player.owned_airships
	hangar_ui.shipwright_popup = self
	hangar_ui.docks_available = docks
	player.add_child(hangar_ui)
	self.hide()

func _close_popup():
	player.set_physics_process(true)
	player.camera_enabled = true
	self.queue_free()
