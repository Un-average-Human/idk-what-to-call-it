extends TextureButton

@export var item_resource: Resource
@export var animation_speed: float = 0.25

func _ready() -> void:
	focus_mode = Control.FOCUS_ALL
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)
	
	mouse_entered.connect(_on_focus_entered)
	mouse_exited.connect(_on_focus_exited)
	
	_on_focus_exited()

	if item_resource:
		if item_resource.texture:
			texture_normal = item_resource.texture


func _on_focus_entered():
	var focus_tween = create_tween().set_parallel(true)
	focus_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	
	focus_tween.tween_property(self, "scale", Vector2(1.2, 1.2), animation_speed)
	focus_tween.tween_property(self, "modulate", Color(1.5, 1.5, 1.5), animation_speed)
	print("Mouse entered the container!")

func _on_focus_exited():
	var focus_tween = create_tween().set_parallel(true)
	focus_tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	
	focus_tween.tween_property(self, "scale", Vector2(1.0, 1.0), animation_speed)
	focus_tween.tween_property(self, "modulate", Color(1, 1, 1), animation_speed)
	print("Mouse left the container!")
