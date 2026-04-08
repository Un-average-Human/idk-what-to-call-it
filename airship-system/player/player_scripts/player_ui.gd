extends CanvasLayer

@onready var wallet_label: Label = $wallet

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.update_wallet.connect(_update_wallet)

func _update_wallet(wallet):
	wallet_label.text = "moneh:" + str(int(wallet))
