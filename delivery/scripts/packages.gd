extends RigidBody3D
class_name Package

enum package_type{COFFEE, IRON, ALUMINIUM, FLOUR, GOLD, SILK, COAL, WOOD, MILK, WINE}
@export var weight: int
@export var base_price: float
@export var type: package_type
var original_owner: String
var current_owner
