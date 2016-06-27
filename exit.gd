
extends StaticBody

# member variables here, example:
# var a=2
# var b="textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	
func damage(_):
	if get_translation().distance_to(get_node("../Player").get_translation()) < 20:
		get_node("SamplePlayer").play("victory")
		get_node("/root/World/Label").set_message("LEVEL CLEARED!")
		get_node("Timer").start()
		get_node("/root/Global").add_score(1000)
		
func _on_Timer_timeout():
	get_node("/root/Global").level += 1
	get_tree().reload_current_scene()
