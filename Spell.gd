extends RigidBody

export var SPEED = 10

var cast = false

func _ready():
	set_as_toplevel(true)
	
func _physics_process(delta):
	if cast:
		apply_impulse(transform.basis.z, -transform.basis.z * SPEED)

func _on_Area_body_entered(body):
	if body.is_in_group("Mobs"):
		body.health -= 1
	
	queue_free()
