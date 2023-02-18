extends Spatial


func _ready():
	var data = yield($"%VillageGen", "finished")
	var splatmap = $"%Terrain".get_node("terrain").material_override.get_shader_param("splatmap")
	splatmap.create_from_image(data["road_img"])
	$"%Terrain".get_node("terrain").material_override.set_shader_param("splatmap", splatmap)
	
	for i in data["houses"]:
		var house: Spatial = preload("res://VillageGen/House/House.tscn").instance()
		$"%Houses".add_child(house)
		var pos = i.get_origin() - $"%VillageGen".terrain_size / 2
		house.translation = Vector3(pos.x, 0, pos.y) / 2
		house.rotate_y(i.get_rotation())
	
	$"%VillageGen".queue_free()
