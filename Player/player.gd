extends KinematicBody

onready var head = $Head
onready var sprint_timer = $SprintTimer
onready var aimcast = $Head/Camera/AimCast
onready var staff = $Head/Hand/Staff
onready var staff_tip = $Head/Hand/Staff/StaffTip
onready var HUD_spell = $Head/Camera/HUD/Spell

onready var spellScene = preload("res://Spell.tscn")

var move_dir = Vector3.ZERO
var velocity = Vector3.ZERO
var snap_vector = Vector3.ZERO
var speed 
var spell_combination = ""
var spell_count = 1

var is_sprinting = false

export var MOUSE_SENSITIVITY = 0.2
export var MAX_ANGLE = 90
export var MIN_ANGLE = -80

export var DEF_SPEED = 10
export var SPRINT_SPEED = 20

export var ACCELERATION = 10
export var GRAVITY = 50
export var JUMP_SPEED = 15

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	
	# quit game debug
	if Input.is_action_just_pressed("ui_quit"):	
		get_tree().quit()
		
	# spell count swapping
	if Input.is_action_just_released("switch_up"):
		spell_count = spell_count % 3 + 1
		spell_combination = ""
	elif Input.is_action_just_released("switch_down"):
		spell_count = (spell_count + 1) % 3 + 1
		spell_combination = ""
	if Input.is_action_just_pressed("switch_slot1"):
		spell_count = 1
		spell_combination = ""
	elif Input.is_action_just_pressed("switch_slot2"):
		spell_count = 2
		spell_combination = ""
	elif Input.is_action_just_pressed("switch_slot3"):
		spell_count = 3 
		spell_combination = ""
	# spell casting
	if Input.is_action_just_pressed("spellA"):
		if len(spell_combination) < spell_count:
			spell_combination += "A"
			
	if Input.is_action_just_pressed("spellB"):
		if len(spell_combination) < spell_count:
			spell_combination += "B"		
	
	# HUD spell combo display
	if len(spell_combination) > 0:
		HUD_spell.text = spell_combination
	else:
		HUD_spell.text = "_ ".repeat(spell_count)		
		
	if len(spell_combination) == spell_count:
		if aimcast.is_colliding():
			var spell = spellScene.instance()
			staff_tip.add_child(spell)
			spell.look_at(aimcast.get_collision_point(), Vector3.UP)
			spell.type = spell_combination
			spell.cast()
		
		spell_combination = ""
		
	# sprinting
	speed = DEF_SPEED
	
	if Input.is_action_just_pressed("sprint"):
		is_sprinting = !is_sprinting
		
	if is_sprinting: 
		speed = SPRINT_SPEED
		
	# vertical movement
	snap_vector = Vector3.DOWN
	
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		snap_vector = - get_floor_normal()
		if Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_SPEED
			snap_vector = Vector3.ZERO
	
	# horizontal movement
	move_dir = Vector3(
		Input.get_action_strength("right") - Input.get_action_strength("left"), 
		0,  
		Input.get_action_strength("backward") - Input.get_action_strength("forward")
		).normalized().rotated(Vector3.UP, rotation.y)
		
	velocity.x = lerp(velocity.x, move_dir.x * speed, ACCELERATION * delta)
	velocity.z = lerp(velocity.z, move_dir.z * speed, ACCELERATION * delta)
	
	velocity = move_and_slide_with_snap(velocity, snap_vector, Vector3.UP, true)

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * MOUSE_SENSITIVITY))
		head.rotate_x(-deg2rad(event.relative.y * MOUSE_SENSITIVITY))
		head.rotation.x = clamp(head.rotation.x, deg2rad(MIN_ANGLE), deg2rad(MAX_ANGLE))

func _on_SprintTimer_timeout():
	is_sprinting = false
