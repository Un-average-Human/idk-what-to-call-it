extends StaticBody3D

@onready var sell_area: Area3D = $"../sell_packages"
var price_multipliers: Dictionary[Package.package_type, float] = {
	Package.package_type.COFFEE: 2.0,
	Package.package_type.IRON: 1.0,
	Package.package_type.ALUMINIUM: 1.0,
	Package.package_type.FLOUR: 1.0,
	Package.package_type.GOLD: 1.0,
	Package.package_type.SILK: 1.0,
	Package.package_type.COAL: 1.0,
	Package.package_type.WOOD: 1.0,
	Package.package_type.MILK: 1.0,
	Package.package_type.WINE: 1.0
	}

func _sell_package():
	print("function called")
	var packages = sell_area.get_overlapping_bodies()
	for package in packages:
		if package is Package:
			var revenue = package.base_price * price_multipliers.get(package.type)
			package.current_owner.wallet += revenue
			print("wallet value should've increased")
			package.queue_free()
