extends Node

#moneh
var wallet: float = 500.0: set = _set_wallet

#airship
var owned_airships: Array[AirshipData]
var airship_spawned: RigidBody3D

#gears
var owned_gear: Array

#pilot
var can_move := true
var is_piloting := false
var is_seating := false

func _set_wallet(new_value):
	if wallet != new_value:
		wallet = new_value
		SignalBus.update_wallet.emit(wallet)
