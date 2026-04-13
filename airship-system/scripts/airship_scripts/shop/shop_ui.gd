extends CanvasLayer

@export var description_panel_button: Button
@export var description_panel: VBoxContainer
@export var description_label: RichTextLabel
@export var speed_label: RichTextLabel
@export var capacity_label: RichTextLabel
@export var size_label: RichTextLabel
@export var price_label: RichTextLabel
@export var purchase_button: Button
var selected_airship: AirshipData
@export var airship_panel_button: Button
@export var airships_to_buy: HBoxContainer
@export var airship_button_container: VBoxContainer
var airship_button_group: ButtonGroup = ButtonGroup.new()
var shipwright_popup: CanvasLayer
@export var close_button: Button
var airships: Array
var player: CharacterBody3D
@export var airship_preview_marker: Marker3D
var airship_preview: RigidBody3D

func _ready() -> void:
	#orders the airships by price, with the cheapest one coming up first
	airships.sort_custom(func(a, b): return a.price < b.price)
	
	#creates new buttons for each airship
	for airship_data in airships:
		var airship_button = Button.new()
		airship_button.text = airship_data.airship_name
		airship_button.toggle_mode = true
		airship_button.button_group = airship_button_group
		airship_button.custom_minimum_size = Vector2(175, 50)
		airship_button_container.add_child(airship_button)
		airship_button.toggled.connect(_on_airship_button_toggled.bind(airship_button, airship_data))
	
	airship_button_container.get_child(0).toggled.emit(true)
	airship_button_container.get_child(0).button_pressed = true
	
	description_panel_button.toggled.connect(_on_button_toggled.bind(description_panel_button))
	airship_panel_button.toggled.connect(_on_button_toggled.bind(airship_panel_button))
	purchase_button.pressed.connect(_on_airship_purchased_pressed)
	close_button.pressed.connect(_close_shop)
	

func _on_button_toggled(toggled_on: bool, button: Button):
	match button:
		description_panel_button:
			if toggled_on:
				var tween = create_tween()
				tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
				tween.tween_property(description_panel, "global_position:y", 618.0, 1)
			else:
				var tween = create_tween()
				tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
				tween.tween_property(description_panel, "global_position:y", 418.0, 1)
		airship_panel_button:
			if toggled_on:
				var tween = create_tween()
				tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
				tween.tween_property(airships_to_buy, "global_position:x", -200.0, 1)
			else:
				var tween = create_tween()
				tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
				tween.tween_property(airships_to_buy, "global_position:x", 0.0, 1)

func _on_airship_button_toggled(toggled_on: bool, button: Button, airship_button_data: AirshipData):
	if toggled_on:
		var root = player.get_tree().root
		selected_airship = airship_button_data
		airship_preview = selected_airship.airships_scene.instantiate()
		
		airship_preview.is_preview = true
		airship_preview.freeze = true
		for collision_shape in airship_preview.get_children():
			if collision_shape is CollisionShape3D:
				collision_shape.queue_free()
		
		airship_preview.is_preview = true
		root.add_child(airship_preview)
		airship_preview.global_position = airship_preview_marker.global_position
		var camera_arm = airship_preview.get_node("camera_arm")
		camera_arm.global_position = airship_preview.global_position
		camera_arm.clear_excluded_objects()
		camera_arm.add_excluded_object(airship_preview)
		camera_arm.force_update_transform()
		camera_arm.get_child(0).make_current()
		
		airship_preview.player_driving = player
		
		speed_label.text = "Speed: " + str(airship_button_data.speed) + "KM/H"
		capacity_label.text = "Capacity: " + str(airship_button_data.capacity) + "kg"
		size_label.text = "Size: " + str(airship_button_data.size) + "m"
		price_label.text = "Price: $" + str(airship_button_data.price)
		description_label.text = str(airship_button_data.description)
		
		if player.owned_airships.has(airship_button_data):
			purchase_button.disabled = true
		else:
			purchase_button.disabled = false

func _on_airship_purchased_pressed():
	if selected_airship == null:
		return
	if player.wallet >= selected_airship.price:
		player.wallet -= selected_airship.price
		player.owned_airships.append(selected_airship)
		purchase_button.disabled = true

func _close_shop():
	airship_preview.queue_free()
	shipwright_popup.show()
	shipwright_popup = null
	player.player_camera.make_current()
	self.queue_free()
