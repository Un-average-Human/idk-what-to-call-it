extends CanvasLayer

@export var shop_button: Button
@export var hangar_button: Button
@export var close_button: Button
@export var shipwright_name_label: RichTextLabel

var shop_ui_scene = preload("uid://tbspm3kva16q")
var player: CharacterBody3D
var airship_data: Array[AirshipData]

var shipwright_name: String

func _ready() -> void:
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
	pass

func _close_popup():
	self.queue_free()
