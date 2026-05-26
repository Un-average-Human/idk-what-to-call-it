extends Control

@onready var start_game: Button = %start_game
@onready var leave_lobby: Button = %leave_lobby

@onready var member_board: VBoxContainer = %player_board
@onready var lobby_name_label: Label = %lobby_name
@onready var member_amount_label: Label = %player_amount
@onready var lobby_code_label: Label = %lobby_code

@onready var chat_output: RichTextLabel = %chat_output
@onready var message_box: LineEdit = $chat/Control/message
@onready var send_message_button: Button = $chat/Control/send_message

var lobby_members: Array = []
var max_members: int
var is_host: bool = false
var lobby_code: String = ""
var lobby_name: String

func _ready() -> void:
	MultiplayerLobbies.send_message.connect(_on_message_received)
	MultiplayerLobbies.add_to_player_list.connect(_add_player_to_board)
	
	leave_lobby.pressed.connect(_leave_lobby)
	
	send_message_button.pressed.connect(_send_chat_message)
	message_box.text_submitted.connect(_send_chat_message)

func _on_message_received(message: String) -> void:
	chat_output.add_text("\n" + message)

func _send_chat_message(message: String = message_box.text):
	message = message_box.text
	if !message.strip_edges().is_empty():
		var sent = Steam.sendLobbyChatMsg(MultiplayerPlayer.lobby_id, message)
		if !sent:
			MultiplayerLobbies._display_message("Message could not be sent")
	message_box.text = ""

func _add_player_to_board(steam_id: int, steam_name: String):
	MultiplayerPlayer.lobby_members.append({"steam_id" : steam_id, "steam_name" : steam_name})
	for member in member_board.get_children():
		member.queue_free()
	
	member_amount_label.text = str(MultiplayerPlayer.lobby_members.size()) + "/" + str(MultiplayerLobbies.max_member_count) + " Players"
	
	for member in MultiplayerPlayer.lobby_members:
		var member_label: Label = Label.new()
		member_label.text = str(steam_name)
		member_board.add_child(member_label)

func _lobby_created():
	lobby_name_label.text = lobby_name
	if !lobby_code.is_empty():
		lobby_code_label.text = "Lobby code: " + lobby_code
	else:
		lobby_code_label.text = ""
	
	MultiplayerLobbies._create_lobby(MultiplayerLobbies.lobby_type, max_members)

func _leave_lobby():
	if MultiplayerPlayer.lobby_id != 0:
		Steam.leaveLobby(MultiplayerPlayer.lobby_id)
		for member in MultiplayerPlayer.lobby_members:
			if member['steam_id'] != MultiplayerPlayer.steam_id:
				Steam.closeP2PSessionWithUser(member['steam_id'])
		MultiplayerPlayer.lobby_members.clear()
		MultiplayerPlayer.lobby_id = 0
	var main_menu_scene = load("uid://71bmn0d7714o")
	if main_menu_scene:
		var menu_instance = main_menu_scene.instantiate()
		get_tree().root.add_child(menu_instance)
		queue_free()

	
