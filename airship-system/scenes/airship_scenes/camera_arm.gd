extends SpringArm3D

@export var airship: RigidBody3D
@export var max_zoom_out: int
@export var max_zoom_in: int

func _ready() -> void:
	top_level = true
	add_excluded_object(get_parent())

func _input(event: InputEvent) -> void:
	if airship.player_driving == null:
		return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		add_excluded_object(self)
		var SENSITIVITY = airship.player_driving.SENSITIVITY
		rotation.y -= event.relative.x * SENSITIVITY
		
		rotation.x -= event.relative.y * SENSITIVITY
		rotation.x = clamp(rotation.x, -PI/2, PI/4)
	
	if Input.is_action_just_pressed("WheelUp") and spring_length > max_zoom_in:
		spring_length -= 1
	elif Input.is_action_just_pressed("WheelDown") and spring_length < max_zoom_out:
		spring_length += 1
