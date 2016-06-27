
extends KinematicBody

onready var player = get_node("/root/World/Player")
onready var sound = get_node("SpatialSamplePlayer")
var velocity
var walk_to = Vector3(0,0,1)
const SPEED = 30
const MEMORY = 4
var remember = 0
var footsteps = 0
var hp = 4
var move = false

func _ready():
	set_process(true)
	set_fixed_process(true)
	
func _process(delta):
	if move:
		if remember > 0:
			remember -= delta
	look_at(player.get_translation(), Vector3(0,1,0))

func damage(amount):
	hp -= amount
	if hp <= 0:
		var explosion = load("res://explosion.scn").instance()
		explosion.set_translation(get_translation())
		get_node("..").add_child(explosion)
		get_node("/root/Global").add_score(50)
		queue_free()
		if randf() < 0.5:
			get_node("/root/Global").spawn_loot(get_translation())
		

func _fixed_process(delta):
	var space = get_world().get_direct_space_state()
	var result = space.intersect_ray(get_translation()+Vector3(0,10,0), player.get_translation()+Vector3(0,10,0), [self])
	if not result.empty() and result["collider"] == player:
		walk_to = player.get_translation()
		walk_to.y = 0
		remember = MEMORY
	if remember > 0:
		look_at(walk_to, Vector3(0,1,0))
		velocity = -get_global_transform().basis.z * SPEED
		var motion = velocity * delta
		motion = move(motion)
		if not sound.is_voice_active(footsteps):
			footsteps = sound.play("footsteps")
	else:
		velocity = 0
	var dist_to_player = get_translation().distance_to(player.get_translation())
	if dist_to_player < 20:
		get_node("Sprite3D").set_frame(1)
		if dist_to_player < 4:
			player.kill("Keep an eye on the gnomes next time...", self)
			sound.play("attack")
	else:
		get_node("Sprite3D").set_frame(0)

func _on_VisibilityNotifier_enter_screen():
	move = false
	set_fixed_process(false)
	if sound.is_voice_active(footsteps):
		sound.stop_voice(footsteps)


func _on_VisibilityNotifier_exit_screen():
	move = true
	set_fixed_process(true)