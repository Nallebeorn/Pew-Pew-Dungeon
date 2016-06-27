
extends StaticBody

var hp = 2.5

func _ready():
	set_fixed_process(true)

func damage(amount):
	hp -= amount
	if hp <= 0:
		get_node("/root/Global").spawn_loot(get_translation())
		queue_free()
		
func _fixed_process(delta):
	var look_at = get_node("/root/World/Player").get_translation()
	look_at.y = 0
	look_at(look_at, Vector3(0, 1, 0))