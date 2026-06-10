@tool
extends Control

@export var animation_speed: float = 0.1
@export var radius: float = 150:
	set(value):
		radius = value
		_refresh()

var tween: Tween

func _ready() -> void:
	scale = Vector2(0.001, 0.001)
	hide()
	child_entered_tree.connect(_refresh)
	child_exiting_tree.connect(_on_child_exiting)
	
	_refresh()

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Q"):
		if tween and tween.is_valid():
			tween.kill()
			
		show()
		tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self, "scale", Vector2.ONE, animation_speed)

	if Input.is_action_just_released("Q"):
		if tween and tween.is_valid():
			tween.kill()
			
		tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self, "scale", Vector2.ZERO, animation_speed)
		tween.tween_callback(hide)
		_select_item()

func _refresh(_child = null):
	var spacing = TAU / get_child_count()
	
	for child: Control in get_children():
		var index = child.get_index()
		var angle = spacing * index - PI / 2
		var target_dir = Vector2(radius, 0).rotated(angle)
		
		child.position = target_dir - child.size / 2

func _on_child_exiting(_node):
	await get_tree().process_frame
	
	_refresh()

func _select_item():
	var selected_node = get_viewport().gui_get_focus_owner()
	
	if selected_node and selected_node.is_ancestor_of(self) or selected_node in get_children():
		if "item_resource" in selected_node and selected_node.item_resource != null:
			var selected_item = selected_node.item_resource
			
			#yadda yadda
			
			print("Selected item: ", selected_item.resource_name)
