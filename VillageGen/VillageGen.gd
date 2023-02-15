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

export var path_noise: OpenSimplexNoise
export var size: Vector2

var astar = AStar2D.new()
var astar_point_map = {}


func _ready():
	yield(self, "draw")
	randomize()
	path_noise.seed = randi()
	var road_img = Image.new()
	road_img.create(size.x * 2, size.y * 2, true, Image.FORMAT_R8)
	road_img.lock()
	for x in range(-size.x, size.x):
		for y in range(-size.y, size.y):
			var xy = Vector2(x, y)
			var weight = path_noise.get_noise_2dv(xy) / 2 + 0.5
			var id = astar.get_available_point_id()
			astar.add_point(id, xy, weight * 20)
			astar_point_map[xy] = id
#			draw_rect(Rect2(xy * 10, Vector2(10, 10)), Color().from_hsv(0, 0, weight))
			var road_bias = 0.03
			if weight > 0.5 - road_bias and weight < 0.5 + road_bias:
#				draw_circle(xy * 10, 3, Color.aqua)
				var shape = CollisionShape2D.new()
				shape.shape = CircleShape2D.new()
				shape.shape.radius = 7.5
				shape.position = xy * 10
				$StaticBody2D.add_child(shape)
				road_img.set_pixelv(xy + size, Color.white)
			else:
				road_img.set_pixelv(xy + size, Color.black)
	road_img.save_png("res://test.png")
	
	for center in astar.get_points():
		for direction in DIR:
			var neighbor = astar_point_map.get(astar.get_point_position(center) + direction, false)
			if neighbor:
				astar.connect_points(center, neighbor)
	
	var house_density = 8
	var house_grid_size = size / house_density
	var house_offset = 1
	for x in range(-house_grid_size.x + house_offset, house_grid_size.x - house_offset):
		for y in range(-house_grid_size.y + house_offset, house_grid_size.y - house_offset):
			var xy = Vector2(x, y) * 8 + size / house_density
			var house = $House.duplicate()
			house.position = xy * 10
			add_child(house)
	
#	get_tree().paused = true

func rand_point_in_circle(p_radius):
	var r = sqrt(randf()) * p_radius
	var t = randf() * TAU
	return Vector2(r * cos(t), r * sin(t))

func rand_point_on_circle(p_radius):
	var t = randf() * TAU
	return Vector2(p_radius * cos(t), p_radius * sin(t))

func from_angle(var p_angle):
	return Vector2(cos(p_angle), sin(p_angle))
