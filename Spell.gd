extends RigidBody

export var SPEED = 20.0

var type = ""

func _ready():
	set_as_toplevel(true)
	self.add_to_group("Spells")
	
func cast():
	apply_impulse(transform.basis.z, -transform.basis.z * SPEED)
	
func _on_Area_body_entered(body):
	if body.is_in_group("Mobs"):
		body.check_health(type)
	
	queue_free()

func _on_Area_area_entered(area):
	if area.get_parent().is_in_group("SpellCircles"):
		area.get_parent().rune_update(type)
