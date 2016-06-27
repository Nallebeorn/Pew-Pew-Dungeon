
extends Area

export(String, "damage", "shoot_cooldown", "speed", "money") var stat
var taken = false

func _ready():
	set_process(true)
	
func _process(delta):
	if taken and not get_node("SamplePlayer").is_active():
		queue_free()

func _on_Upgrade_body_enter( body ):
	if not taken:
		if body == get_node("/root/World/Player"):
			get_node("/root/Global").upgrade_stat(stat)
			get_node("SamplePlayer").play("upgrade")
			taken = true
