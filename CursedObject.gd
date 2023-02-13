extends KinematicBody

export var spell_types = ["AAA", "AAB", "ABA", "ABB", "BAA", "BAB", "BBA", "BBB"]

var health = 1
var spell_type

onready var label = $Label3D

func _ready():
	spell_type = spell_types[randi() % spell_types.size()]
	label.text = spell_type	
		
func _process(_delta):
	if health <= 0:
		queue_free()

func check_health(type):
	if spell_type == type:
		health -= 1
