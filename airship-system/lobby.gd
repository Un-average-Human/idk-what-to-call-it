extends Control

@onready var player_board: VBoxContainer = $players/MarginContainer/player_board
@onready var lobby_name_label: Label = $lobby_name
@onready var player_amount_label: Label = $player_amount
@onready var lobby_code_label: Label = $lobby_code

var players: Array = []
var max_players: int
var lobby_code: String
var lobby_name: String

func _lobby_created():
	for player in players:
		var player_label: Label = Label.new()
		player_label.text = player
		player_board.add_child(player_label)
	
	lobby_name_label.text = lobby_name
	if !lobby_code.is_empty():
		lobby_code_label.text = "Lobby code: " + lobby_code
	else:
		lobby_code_label.text = ""
	player_amount_label.text = str(players.size()) + "/" + str(max_players) + " Players"
