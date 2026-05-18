extends Control

@export var lobby_scene: PackedScene

@onready var create_lobby_menu_button: Button = %create_lobby
@onready var join_lobby_menu_button: Button = %join_lobby

@onready var create_lobby_menu: Control = %create_lobby_menu
@onready var join_lobby_menu: Control = %join_lobby_menu

@onready var create_lobby_button: Button = %create_lobby_button

@onready var lobby_type_check: CheckButton = %lobby_type_button
@onready var lobby_code_label: Label = %lobby_code_label

@onready var password_input: LineEdit = %password_input
@onready var lobby_name_input: LineEdit = %lobby_name

func _ready() -> void:
	create_lobby_menu_button.pressed.connect(_lobby_menu.bind(create_lobby_menu_button))
	join_lobby_menu_button.pressed.connect(_lobby_menu.bind(join_lobby_menu_button))
	
	create_lobby_button.pressed.connect(_lobby_menu.bind(create_lobby_button))
	
	lobby_type_check.toggled.connect(_check_button.bind(lobby_type_check))

func _lobby_menu(button: Button):
	match button.name:
		"join_lobby":
			if join_lobby_menu.visible == false:
				_hide_and_show_menu(join_lobby_menu, false)
				_hide_and_show_menu(create_lobby_menu, true)
			else:
				_hide_and_show_menu(join_lobby_menu, true)

		"create_lobby":
			if create_lobby_menu.visible == false:
				_hide_and_show_menu(create_lobby_menu, false)
				_hide_and_show_menu(join_lobby_menu, true)
			else:
				_hide_and_show_menu(create_lobby_menu, true)
		
		
		"create_lobby_button":
			_change_scene(true)

func _hide_and_show_menu(menu: Control, is_hiding: bool):
	if is_hiding:
		menu.hide()
	else:
		menu.show()

func _check_button(toggled_on: bool, button: CheckButton):
	match button.name:
		"lobby_type_button":
			lobby_code_label.visible = toggled_on

func _change_scene(is_creating: bool):
	var lobby = lobby_scene.instantiate()
	get_tree().root.add_child(lobby)
	if is_creating:
		lobby.players.append("temporary")
		if !password_input.text.is_empty() and lobby_code_label.visible:
			lobby.lobby_code = password_input.text
		if !lobby_name_input.text.is_empty():
			lobby.lobby_name = lobby_name_input.text
		else:
			lobby.lobby_name = "temporary user" + "'s lobby"
		lobby._lobby_created()
		queue_free()
