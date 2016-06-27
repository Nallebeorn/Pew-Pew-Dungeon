
extends KinematicBody

const SPEED = 80
var player
var shooter

func _ready():
	player = get_node("/root/World/Player")
	look_at(player.get_translation() + Vector3(0, 5, 0), Vector3(0, 1, 0))
	set_fixed_process(true)

func _fixed_process(delta):
	move(-get_global_transform().basis.z * SPEED * delta)
	if is_colliding():
		if get_collider() == player:
			player.kill("Defeated in gun-fight by a one-eyed machine.", shooter)
		destroy()

func destroy():
	var explosion = load("res://explosion.scn").instance()
	explosion.set_translation(get_translation())
	get_node("/root/World").add_child(explosion)
	queue_free()