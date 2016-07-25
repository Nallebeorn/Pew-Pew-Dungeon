
extends StaticBody

onready var player = get_node("/root/World/Player")
onready var anim = get_node("AnimationPlayer")
onready var sound = get_node("SpatialSamplePlayer")
var hp = 5

func _ready():
	set_process(true)
	
func _process(delta):
	look_at(player.get_translation(), Vector3(0,1,0))

func damage(amount):
	hp -= amount
	if hp <= 0:
		var explosion = load("res://explosion.tscn").instance()
		explosion.set_translation(get_translation())
		get_node("..").add_child(explosion)
		sound.play("die")
		queue_free()
		get_node("/root/Global").add_score(50)
		if randf() < 0.5:
			get_node("/root/Global").spawn_loot(get_translation())

func _on_Timer_timeout():
	get_node("Timer").start()
	print("BAMBAM")
	var bullet = preload("res://monsters/bullet.tscn").instance()
	bullet.set_translation(get_node("Gun").get_global_transform().origin)
	bullet.shooter = self
	get_node("/root/World").add_child(bullet)
	sound.play("attack")
	anim.play("attack")
