
extends KinematicBody

const SPEED = 80
var dir = Vector3()
var DAMAGE
	
func _ready():
	DAMAGE = get_node("/root/Global").player_damage
	add_collision_exception_with(get_node("/root/World/Player"))
	set_fixed_process(true)

func _fixed_process(delta):
	move(dir * SPEED * delta)
	if is_colliding() and get_collider().get_name() != "Player":
		if get_collider().has_method("damage"):
			get_collider().damage(DAMAGE)
		print(get_collider().get_name())
		destroy()
	
func destroy():
	var explosion = load("res://explosion.scn").instance()
	explosion.set_translation(get_translation())
	get_node("/root/World").add_child(explosion)
	queue_free()