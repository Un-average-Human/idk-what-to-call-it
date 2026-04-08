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

var airships: Array

var player: CharacterBody3D

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
	
	description_panel_button.toggled.connect(_on_button_toggled.bind(description_panel_button))
	airship_panel_button.toggled.connect(_on_button_toggled.bind(airship_panel_button))
	purchase_button.pressed.connect(_on_airship_spawn_pressed)

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
		selected_airship = airship_button_data
		speed_label.text = "Speed: " + str(airship_button_data.speed) + "KM/H"
		capacity_label.text = "Capacity: " + str(airship_button_data.capacity) + "kg"
		size_label.text = "Size: " + str(airship_button_data.size) + "m"
		description_label.text = str(airship_button_data.description)
		
		if player.owned_airships.has(airship_button_data.airship_name):
			purchase_button.disabled = true
		else:
			purchase_button.disabled = false

func _on_airship_spawn_pressed():
	if selected_airship == null:
		return
	print(selected_airship)
	if player.wallet >= selected_airship.price:
		player.wallet -= selected_airship.price
		player.owned_airships.append(selected_airship.airship_name)
		purchase_button.disabled = true
