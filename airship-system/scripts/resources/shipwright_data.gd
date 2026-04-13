extends Resource
class_name ShipwrightData

@export var shipwright_name: String
@export var shipwright_seller: String
@export var max_docks: int
@export var airships_available: Array[AirshipData]
var docks: Array[Marker3D]
