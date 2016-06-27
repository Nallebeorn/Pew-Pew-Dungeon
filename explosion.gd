
extends Spatial

# member variables here, example:
# var a=2
# var b="textvar"

func _ready():
	get_node("/root/ColorEffect").register(get_node("Sprite3D"))
	get_node("SpatialSamplePlayer").play("small_explosion")




func _on_AnimationPlayer_finished():
	queue_free()
