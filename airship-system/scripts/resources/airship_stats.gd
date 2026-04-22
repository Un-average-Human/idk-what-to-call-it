extends Resource
class_name AirshipStats

@export_group("Scene Objects")
@export var helm_max_rotation: float
@export var rudder_max_rotation: float
@export var propeller_rotating_speed: float

@export_group("Numerical Variables")
@export var turn_power: float
@export var tilt_angle: float

@export var min_lift: float
@export var max_lift: float
@export var lift_increment: float

@export var max_speed: float
@export var speed_increment: float
