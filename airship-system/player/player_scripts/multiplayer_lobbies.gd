extends Node

enum lobby_status {PRIVATE, FRIENDS, PUBLIC, INVISIBLE}
enum lobby_search_dist {CLOSE, DEFAULT, FAR, WORLDWIDE}

var lobby_type
var max_member_count
var members_in_lobby: Array
var lobby_button_container: VBoxContainer

signal send_message(message: String)
signal add_to_player_list(steam_id: int, steam_name: String)
signal change_scene(is_creating: bool, lobbyID: int)

func _ready() -> void:
	Steam.join_requested.connect(_on_lobby_join_requested)
	Steam.lobby_chat_update.connect(_on_lobby_chat_update)
	Steam.lobby_created.connect(_on_lobby_created)
	#Steam.lobby_data_update.connect(_on_lobby_data_update)
	#Steam.lobby_invite.connect(_on_lobby_invite)
	Steam.lobby_joined.connect(_on_lobby_joined)
	Steam.lobby_match_list.connect(_on_lobby_match_list)
	Steam.lobby_message.connect(_on_lobby_message)
	_check_command_line()

#lobby funcs
#checks if the player is in a lobby and if the arent they create a lobby
func _create_lobby(lobby_type, lobby_size: int):
	if MultiplayerPlayer.lobby_id == 0:
		Steam.createLobby(lobby_type, lobby_size)

func _join_lobby(lobby_id: int):
	var name = Steam.getLobbyData(lobby_id, "name")
	_display_message("Joining lobby: " + str(name) + "...")
	MultiplayerPlayer.lobby_members.clear()
	
	Steam.joinLobby(lobby_id)

func _get_lobby_members():
	MultiplayerPlayer.lobby_members.clear()
	
	var member_count = Steam.getNumLobbyMembers(MultiplayerPlayer.lobby_id)
	
	for member in range(0, member_count):
		var member_steam_id = Steam.getLobbyMemberByIndex(MultiplayerPlayer.lobby_id, member)
		var member_steam_name = Steam.getFriendPersonaName(member_steam_id)
		add_to_player_list.emit(member_steam_id, member_steam_name)

func _display_message(message):
	send_message.emit(message)

#lobby func callbacks
func _on_lobby_created(connect: int, lobby_id: int):
	if connect == 1:
		MultiplayerPlayer.lobby_id = lobby_id
		_display_message("Created lobby: " + MultiplayerPlayer.lobby_name)
		
		Steam.setLobbyData(lobby_id, "name", MultiplayerPlayer.lobby_name)
		Steam.setLobbyData(lobby_id, "type", str(lobby_type))


#join lobbies
func _on_lobby_joined(lobby_id: int, permissions: int, locked: bool, response: int):
	MultiplayerPlayer.lobby_id = lobby_id
	var name = Steam.getLobbyData(lobby_id, "name")
	MultiplayerPlayer.lobby_name = str(name)
	_get_lobby_members()

func _on_lobby_join_requested(lobby_id: int, friend_id: int) -> void:
	var owner_name: String = Steam.getFriendPersonaName(friend_id)
	print("Joining " + owner_name + "'s lobby")
	_join_lobby(lobby_id)

func _on_lobby_match_list(lobbies):
	for lobby in lobbies:
		var lobby_name = Steam.getLobbyData(lobby, "name")
		var lobby_member = Steam.getNumLobbyMembers(lobby)
		
		var lobby_button = preload("uid://c81ivwojw4s08").instantiate()
		lobby_button.name = str(lobby)

		var name_label: Label = lobby_button.get_node("%lobby_name_label")
		name_label.text = lobby_name
		
		var member_label: Label = lobby_button.get_node("%member_label")
		member_label.text = str(lobby_member) + "/" + str(max_member_count)
		
		var lobby_type: Label = lobby_button.get_node("%lobby_type_label")
		lobby_type.text = Steam.getLobbyData(lobby, "type")
		if !lobby_type.text.is_empty():
			lobby_type.text[0].to_upper()
		
		var join_button: Button = lobby_button.get_node("%join_button")
		join_button.pressed.connect(func(): change_scene.emit(false, lobby))
		join_button.pressed.connect(_join_lobby.bind(lobby))
		
		lobby_button_container.add_child(lobby_button)

func _on_lobby_chat_update(this_lobby_id: int, change_id: int, making_change_id: int, chat_state: int) -> void:
	var changer: String = Steam.getFriendPersonaName(change_id)

	match chat_state:
		Steam.CHAT_MEMBER_STATE_CHANGE_ENTERED:
			print(changer + " has joined the lobby.")
		Steam.CHAT_MEMBER_STATE_CHANGE_LEFT:
			print(changer + " has left the lobby.")
		Steam.CHAT_MEMBER_STATE_CHANGE_KICKED:
			print(changer + " has been kicked from the lobby.")
		Steam.CHAT_MEMBER_STATE_CHANGE_BANNED:
			print(changer + " has been banned from the lobby.")
		_:
			print(changer + " did... something.")
	_get_lobby_members()

func _on_lobby_message(result, user: int, message: String, type):
	var sender = Steam.getFriendPersonaName(user)
	_display_message(str(sender) + ": " + str(message))

#command line arguments thing
func _check_command_line():
	var args: Array = OS.get_cmdline_args()
	
	if args.size() > 0:
		for arg in args:
			if MultiplayerPlayer.lobby_invite_arg:
				_join_lobby(int(arg))
			if arg == "+connect_lobby":
				MultiplayerPlayer.lobby_invite_arg = true

func _process(delta: float) -> void:
	Steam.run_callbacks()
