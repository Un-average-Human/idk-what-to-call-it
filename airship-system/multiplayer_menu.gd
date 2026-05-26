extends Control

@export var lobby_scene: PackedScene

@onready var create_lobby_menu_button: Button = %create_lobby
@onready var join_lobby_menu_button: Button = %join_lobby

@onready var create_lobby_menu: Control = %create_lobby_menu
@onready var join_lobby_menu: Control = %join_lobby_menu

@onready var create_lobby_button: Button = %create_lobby_button

@onready var lobby_type_check: CheckButton = %lobby_type_button
@onready var lobby_code_label: Label = %lobby_code_label
@onready var passcode_error_label: Label = %passcode_error_label

@onready var password_input: LineEdit = %password_input
@onready var lobby_name_input: LineEdit = %lobby_name
@onready var lobby_size_input: SpinBox = %lobby_size_input
@onready var lobby_button_container: VBoxContainer = %lobby_button_container

func _ready() -> void:
	create_lobby_menu_button.pressed.connect(_lobby_menu.bind(create_lobby_menu_button))
	join_lobby_menu_button.pressed.connect(_lobby_menu.bind(join_lobby_menu_button))
	
	lobby_type_check.toggled.connect(_check_button.bind(lobby_type_check))
	
	create_lobby_button.pressed.connect(_lobby_menu.bind(create_lobby_button))
	
	lobby_size_input.get_line_edit().selecting_enabled = false
	
	MultiplayerLobbies.change_scene.connect(_change_scene)

func _lobby_menu(button: Button):
	match button.name:
		"join_lobby":
			if join_lobby_menu.visible == false:
				_hide_and_show_menu(join_lobby_menu, false)
				_lobbies_available()
				_hide_and_show_menu(create_lobby_menu, true)
				_lobbies_available()
			else:
				_hide_and_show_menu(join_lobby_menu, true)

		"create_lobby":
			if create_lobby_menu.visible == false:
				_hide_and_show_menu(create_lobby_menu, false)
				_hide_and_show_menu(join_lobby_menu, true)
			else:
				_hide_and_show_menu(create_lobby_menu, true)
		
		
		"create_lobby_button":
			_change_scene(true, 0)

func _hide_and_show_menu(menu: Control, is_hiding: bool):
	if is_hiding:
		menu.hide()
	else:
		menu.show()

func _check_button(toggled_on: bool, button: CheckButton):
	match button.name:
		"lobby_type_button":
			lobby_code_label.visible = toggled_on
			
			if toggled_on:
				_lobby_code_changed(password_input.text)
			else:
				create_lobby_button.disabled = false
				passcode_error_label.text = ""

func _change_scene(is_creating: bool, lobbyID: int):
	var lobby = lobby_scene.instantiate()
	get_tree().root.add_child(lobby)
	if is_creating:
		if !password_input.text.is_empty() and lobby_code_label.visible:
			lobby.lobby_code = password_input.text
		if !lobby_name_input.text.is_empty():
			lobby.lobby_name = lobby_name_input.text
		else:
			lobby.lobby_name = MultiplayerPlayer.steam_name + "'s lobby"
		MultiplayerPlayer.lobby_name = lobby.lobby_name
		lobby.max_members = lobby_size_input.value
		MultiplayerLobbies.max_member_count = int(lobby_size_input.value)
		lobby._lobby_created()
		queue_free()
	elif !is_creating:
		MultiplayerLobbies._join_lobby(lobbyID)
		queue_free()

func _lobby_code_changed(new_text: String) -> void:
	if not lobby_code_label.visible:
		create_lobby_button.disabled = false
		passcode_error_label.text = ""
		return

	if new_text.is_empty():
		create_lobby_button.disabled = true
		passcode_error_label.text = "Passcode can't be empty."
		return

	if new_text.begins_with(" "):
		create_lobby_button.disabled = true
		passcode_error_label.text = "Passcode cannot start with a space."
		return

	if new_text.ends_with(" "):
		create_lobby_button.disabled = true
		passcode_error_label.text = "Passcode cannot end with a space."
		return

	create_lobby_button.disabled = false
	passcode_error_label.text = ""

func _lobbies_available():
	var lobby_distance = MultiplayerLobbies.lobby_search_dist.WORLDWIDE
	Steam.addRequestLobbyListDistanceFilter(lobby_distance)
	MultiplayerLobbies.lobby_button_container = lobby_button_container
	Steam.requestLobbyList()
