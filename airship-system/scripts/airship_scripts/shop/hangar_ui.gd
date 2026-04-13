extends CanvasLayer

@export var shipwright_data: ShipwrightData

#HANGAR
@export var airship_preview_marker: Marker3D
@export var empty_hangar_cam: Camera3D
@export var description_panel_button: Button
@export var description_panel: VBoxContainer
@export var description_label: RichTextLabel
@export var speed_label: RichTextLabel
@export var capacity_label: RichTextLabel
@export var size_label: RichTextLabel

@export var go_to_docks_button: Button
var selected_airship: AirshipData

@export var airship_panel_button: Button
@export var airships_to_spawn: HBoxContainer
@export var airship_button_container: VBoxContainer
var airship_button_group: ButtonGroup = ButtonGroup.new()

#DOCKS
@export var hangar_gui: Control
@export var docks_gui: Control
@export var back_to_hangar_button: Button
@export var previous_dock_button: Button
@export var next_dock_button: Button
@export var airship_spawn_button: Button

var shipwright_popup: CanvasLayer
@export var close_button: Button

var airships: Array[AirshipData]

var player: CharacterBody3D

var docks_available: Array[Marker3D]
var dock_index: int = 0
var dock_camera_rotation: Vector3
var airship_preview: RigidBody3D

func _ready() -> void:
	#HANGAR GUI
	#orders the airships by price, with the cheapest one coming up first
	airships.sort()
	
	#creates new buttons for each airship
	for airship_data in airships:
		var airship_button = Button.new()
		airship_button.text = airship_data.airship_name
		airship_button.toggle_mode = true
		airship_button.button_group = airship_button_group
		airship_button.custom_minimum_size = Vector2(175, 50)
		airship_button_container.add_child(airship_button)
		airship_button.toggled.connect(_on_airship_button_toggled.bind(airship_button, airship_data))
	
	if airship_button_container.get_child_count() > 0:
		airship_button_container.get_child(0).toggled.emit(true)
		airship_button_container.get_child(0).button_pressed = true
	else:
		empty_hangar_cam.make_current()
	
	description_panel_button.toggled.connect(_on_button_toggled.bind(description_panel_button))
	airship_panel_button.toggled.connect(_on_button_toggled.bind(airship_panel_button))
	close_button.pressed.connect(_close_shop)
	
	#DOCKS GUI
	airship_spawn_button.pressed.connect(_on_airship_spawn_pressed)
	back_to_hangar_button.pressed.connect(_on_back_to_hangar_pressed)
	go_to_docks_button.pressed.connect(_on_go_to_dock_pressed)
	previous_dock_button.pressed.connect(_select_dock.bind("previous"))
	next_dock_button.pressed.connect(_select_dock.bind("next"))

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
				tween.tween_property(airships_to_spawn, "global_position:x", -200.0, 1)
			else:
				var tween = create_tween()
				tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
				tween.tween_property(airships_to_spawn, "global_position:x", 0.0, 1)

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
		if airship_preview != null:
			camera_arm.get_child(0).make_current()
		elif airship_preview == null:
			print("no airship previews available")
			empty_hangar_cam.make_current()
		
		airship_preview.player_driving = player
		
		selected_airship = airship_button_data
		speed_label.text = "Speed: " + str(airship_button_data.speed) + "KM/H"
		capacity_label.text = "Capacity: " + str(airship_button_data.capacity) + "kg"
		size_label.text = "Size: " + str(airship_button_data.size) + "m"
		description_label.text = str(airship_button_data.description)

func _on_go_to_dock_pressed():
	airship_preview.queue_free()
	airship_preview = null
	dock_camera_rotation = Vector3.ZERO
	hangar_gui.hide()
	docks_gui.show()
	print(airship_preview)
	_select_dock("")

func _on_back_to_hangar_pressed():
	airship_preview.queue_free()
	_on_airship_button_toggled(true, airship_button_group.get_pressed_button(), selected_airship)
	docks_gui.hide()
	hangar_gui.show()

func _select_dock(button_func: String):
	if selected_airship == null:
		return
	if airship_preview != null:
		var previous_camera_arm = airship_preview.get_node_or_null("camera_arm")
		if previous_camera_arm:
			dock_camera_rotation = previous_camera_arm.global_rotation
			airship_preview.queue_free()
	airship_preview = selected_airship.airships_scene.instantiate()
	airship_preview.is_preview = true
	airship_preview.freeze = true
	for collision_shape in airship_preview.get_children():
		if collision_shape is CollisionShape3D:
			collision_shape.queue_free()
	var root = player.get_tree().root
	root.add_child(airship_preview)
	match button_func:
		"previous":
			if dock_index == 0:
				dock_index = docks_available.size() - 1
			else:
				dock_index -= 1
		"next":
			#subtract one because arrays start counting from 0, not 1
			if dock_index == docks_available.size() - 1:
				dock_index = 0
			else:
				dock_index += 1
		_:
			dock_index = 0
	var camera_arm: SpringArm3D = airship_preview.get_node("camera_arm")
	airship_preview.global_position = docks_available[dock_index].global_position
	
	camera_arm.global_rotation = dock_camera_rotation
	#reddit magic, idk how this stops the camera from flickering
	camera_arm.global_position = airship_preview.global_position
	camera_arm.clear_excluded_objects()
	camera_arm.add_excluded_object(airship_preview)
	camera_arm.force_update_transform()
	
	airship_preview.player_driving = player
	camera_arm.get_child(0).make_current()

func _on_airship_spawn_pressed():
	airship_preview.queue_free()
	if selected_airship == null:
		return
	if player.airship_spawned != null:
		player.airship_spawned.queue_free()
	var airship_spawned = selected_airship.airships_scene.instantiate()
	var root = player.get_tree().root
	root.add_child(airship_spawned)
	airship_spawned.global_position = docks_available[dock_index].global_position
	player.airship_spawned = airship_spawned
	player.get_node("neck").get_child(0).make_current()
	_close_shop()

func _close_shop():
	shipwright_popup.show()
	shipwright_popup = null
	player.player_camera.make_current()
	self.queue_free()
