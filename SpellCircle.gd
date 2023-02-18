extends Spatial

export var num_runes = 5 
export var spell_types = [0, 1, 2, 3]
export var active_color = Color(0.05, 1.0, 0.5, 1.0)
export var inactive_color = Color(1.0, 1.0, 1.0, 1.0)

onready var area = $Area
onready var timer = $Timer
onready var force_field = $Visuals/ForceField

var rune_list = []
var spell_list = []
var temp_spell_list = []
var temp_idx_list = []

var rel_idx = null
var is_activated = false

func _ready():
	self.add_to_group("SpellCircles")
	
	for i in num_runes:
		var rune = Spatial.new()
		var rune_text = preload("res://RuneSprite/RuneSprite.tscn").instance()
		
		rune_text.frame = spell_types[randi() % spell_types.size()]
		rune_text.translate(Vector3(0, 0, 3.25))
		
		rune.add_child(rune_text)
		rune.rotate_y(deg2rad((i - 1) * 360/num_runes))
		
		add_child(rune)
		
		spell_list.append(rune_text.frame)
		temp_spell_list.append(rune_text.frame)
		temp_idx_list.append(i)
		
		rune_list.append(rune_text)

func rune_update(type):
	var idx = temp_spell_list.find(type, 0) 
	
	if !is_activated:
		if idx >= 0:		
			if rel_idx == null:
				timer.start()	
								
				rel_idx = 1
				
				temp_spell_list = cycle(-idx, temp_spell_list)
				temp_idx_list = cycle(-idx, temp_idx_list)
				
				rune_list[temp_idx_list[0]].modulate = active_color
				temp_spell_list[0] = null
				
			elif idx == rel_idx:				
				timer.stop()
				timer.start()
				
				rune_list[temp_idx_list[idx]].modulate = active_color
				temp_spell_list[idx] = null	
				
				if rel_idx == num_runes - 1:
					force_field.visible = true
					timer.stop()
				
				rel_idx += 1		
			else:
				_reset()
		else:
			_reset()
		
func _reset():
	timer.stop()
	rel_idx = null;
	
	for i in num_runes:
		rune_list[i].modulate = inactive_color
		temp_spell_list[i] = spell_list[i]
		temp_idx_list[i] = i		
	
func _rewind():
	rel_idx -= 1
	rune_list[temp_idx_list[rel_idx]].modulate = inactive_color
	temp_spell_list[rel_idx] = spell_list[temp_idx_list[rel_idx]]	
		
func cycle(times : int, arr : Array):
	times = posmod(times, arr.size())
	var temp_arr = []
	temp_arr.resize(arr.size())
	for i in arr.size():
		temp_arr[(i + times) % arr.size()] = arr[i]
	return temp_arr

func _on_Timer_timeout():
	_rewind()
