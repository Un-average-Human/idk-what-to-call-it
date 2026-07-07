@tool
extends Control

@export var animation_speed: float = 0.1
@export var radius: float = 150:
	set(value):
		radius = value
		_refresh()

@export var starter_menu: Control
var current_menu: Control
var menus: Array[Control]
var menu_id: int = 0

var tween: Tween

func _ready() -> void:
	for menu in get_children():
		menus.append(menu)
		menu.scale = Vector2(0.001, 0.001)
		menu.hide()
		menu.child_entered_tree.connect(_refresh)
		menu.child_exiting_tree.connect(_on_child_exiting)
	current_menu = menus[menu_id]
	
	_refresh()

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Q"):
		if tween and tween.is_valid():
			tween.kill()
			
		current_menu.show()
		tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(current_menu, "scale", Vector2.ONE, animation_speed)
	if Input.is_action_just_released("Q"):
		if tween and tween.is_valid():
			tween.kill()
			
		tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(current_menu, "scale", Vector2.ZERO, animation_speed)
		tween.tween_callback(current_menu.hide)
		_select_item()

	if Input.is_action_just_pressed("G"):
		if current_menu == menus[menus.size() - 1]:
			current_menu == menus[0]
		else:
			menu_id += 1
			current_menu = menus[menu_id]
			
	if Input.is_action_just_pressed("F"):
		if current_menu == menus[0]:
			current_menu == menus[menus.size() - 1]
		else:
			menu_id -= 1
			current_menu = menus[menu_id]

func _refresh(_child = null):
	var spacing = TAU / current_menu.get_child_count()
	
	for child: Control in current_menu.get_children():
		var index = child.get_index()
		var angle = spacing * index - PI / 2
		var target_dir = Vector2(radius, 0).rotated(angle)
		
		child.position = target_dir - child.size / 2

func _on_child_exiting(_node):
	await get_tree().process_frame
	
	_refresh()

func _select_item():
	var selected_node = get_viewport().gui_get_focus_owner()
	
	if selected_node:
		if selected_node.item_resource:
			var selected_item = selected_node.item_resource
			print("Selected item: ", selected_item.item_name)

func _close_menu():
	pass

func _open_menu():
	pass
