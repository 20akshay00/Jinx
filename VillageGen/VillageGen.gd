extends Node2D

const ZERO = Vector2(0, 0)
const ONE = Vector2(1, 1)
const RIGHT = Vector2(1, 0)
const DOWN_RIGHT = Vector2(1, 1)
const DOWN = Vector2(0, 1)
const DOWN_LEFT = Vector2(-1, 1)
const LEFT = Vector2(-1, 0)
const UP_LEFT = Vector2(-1, -1)
const UP = Vector2(0, -1)
const UP_RIGHT = Vector2(1, -1)

const DIR = [
	RIGHT,
	DOWN_RIGHT,
	DOWN,
	DOWN_LEFT,
	LEFT,
	UP_LEFT,
	UP,
	UP_RIGHT,
]

signal finished(data)

export var path_noise: OpenSimplexNoise
export var sand_second_layer_noise: OpenSimplexNoise
export var terrain_size: Vector2
export var house_grid_size: Vector2
export var house_world_size: Vector2
export var road_bias: float

var astar = AStar2D.new()
var astar_point_map = {}


func _ready():
	yield(self, "draw")
	randomize()
	path_noise.seed = randi()
	sand_second_layer_noise.seed = randi()
	
	var road_img = Image.new()
	road_img.create(terrain_size.x, terrain_size.y, true, Image.FORMAT_RGBA8)
	road_img.lock()
	
	for x in terrain_size.x:
		for y in terrain_size.y:
			var xy = Vector2(x, y)
			var weight = path_noise.get_noise_2dv(xy) / 2 + 0.5
			var id = astar.get_available_point_id()
			astar.add_point(id, xy, weight * 20)
			astar_point_map[xy] = id
			
			var is_road = weight > 0.5 - road_bias and weight < 0.5 + road_bias
			var rgba = Color.black
			rgba.r = pow(sand_second_layer_noise.get_noise_2dv(xy) / 2.0 + 0.5, 2)
			rgba.g = 1 if is_road else 0
			road_img.set_pixelv(xy, rgba)
			if is_road:
				var road = $Prefabs/Road.duplicate()
				$Roads.add_child(road)
				road.position = xy
	
	for center in astar.get_points():
		for direction in DIR:
			var neighbor = astar_point_map.get(astar.get_point_position(center) + direction)
			if neighbor:
				astar.connect_points(center, neighbor)
	
	for x in house_grid_size.x:
		for y in house_grid_size.y:
			var xy = Vector2(x, y)
			var house = $Prefabs/House.duplicate()
			$Houses.add_child(house)
			house.position = xy * terrain_size / house_grid_size + terrain_size / house_grid_size / 2
	
	$Prefabs.queue_free()
	
	yield(get_tree().create_timer(1), "timeout")
	update()
	yield(self, "draw")
	
	for i in $Houses.get_children():
		var c = astar.get_closest_point(i.position)
		draw_circle(i.position, 2, Color.red)
		draw_circle(astar.get_point_position(c), 2, Color.green)
		i.look_at(astar.get_point_position(c))
	
	var house_transforms = []
	for i in $Houses.get_children():
		house_transforms.append(i.transform)
	
	road_img.unlock()
	road_img.resize(64, 64, Image.INTERPOLATE_CUBIC)
	road_img.lock()
	var data = {
		"road_img": road_img,
		"houses": house_transforms
	}
	emit_signal("finished", data)

func rand_point_in_circle(p_radius):
	var r = sqrt(randf()) * p_radius
	var t = randf() * TAU
	return Vector2(r * cos(t), r * sin(t))

func rand_point_on_circle(p_radius):
	var t = randf() * TAU
	return Vector2(p_radius * cos(t), p_radius * sin(t))

func from_angle(var p_angle):
	return Vector2(cos(p_angle), sin(p_angle))
