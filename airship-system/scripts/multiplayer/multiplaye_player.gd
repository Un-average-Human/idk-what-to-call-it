extends Node

#steam vars
var game_owned: bool = false
var steam_id: int = 0
var steam_name: String = ""
var is_online: bool = false

#lobby vars
var data
var lobby_id: int = 0
var lobby_name: String
var lobby_members: Array = []
var lobby_invite_arg: bool = false

func _ready() -> void:
	#checks if the user uh... is opening with a steam acc
	var init = Steam.get_steam_init_result()
	if init["status"] > 0:
		print("Steam could not be initialised, Error: ", init["verbal"])
		get_tree().quit()
	
	#set the vars
	is_online = Steam.loggedOn()
	steam_id = Steam.getSteamID()
	steam_name = Steam.getPersonaName()
	game_owned = Steam.isSubscribed()
	
	#checks if the user owns the game
	if game_owned == false:
		print("heyyyy buddy... you could yk... buy it and support me... maybe waybe")
