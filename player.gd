extends KinematicBody

onready var head = $Head
onready var sprint_timer = $SprintTimer
onready var aimcast = $Head/Camera/AimCast
onready var staff_tip = $Head/Staff/StaffTip
onready var spellScene = preload("res://Spell.tscn")

var move_dir = Vector3.ZERO
var velocity = Vector3.ZERO
var snap_vector = Vector3.ZERO
var speed 

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
		
	# Spell casting
	if Input.is_action_just_pressed("cast"):
		if aimcast.is_colliding():
			var spell = spellScene.instance()
			staff_tip.add_child(spell)
			spell.look_at(aimcast.get_collision_point(), Vector3.UP)
			spell.cast = true
		
	# Sprinting
	speed = DEF_SPEED
	
	if Input.is_action_just_pressed("sprint"):
		is_sprinting = !is_sprinting
		
	if is_sprinting: 
		speed = SPRINT_SPEED
		
	# Vertical movement
	snap_vector = Vector3.DOWN
	
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		snap_vector = - get_floor_normal()
		if Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_SPEED
			snap_vector = Vector3.ZERO
	
	# Horizontal movement
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
