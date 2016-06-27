
extends KinematicBody

onready var player = get_node("/root/World/Player")
onready var anim = get_node("AnimationPlayer")
onready var sound = get_node("SpatialSamplePlayer")
var velocity
var walk_to = Vector3(0,0,1)
const SPEED = 10
const MEMORY = 5
var remember = 0
var footsteps = 0
var hp = 3
var stunned = 0
const STUN_TIME = 0.7
var attack = false

func _ready():
	set_process(true)
	set_fixed_process(true)
	
func _process(delta):
	if not anim.is_playing():
		anim.play("walk")
	if remember > 0:
		remember -= delta
	if stunned > 0:
		stunned -= delta
	look_at(player.get_translation(), Vector3(0,1,0))

func damage(amount):
	hp -= amount
	if hp <= 0:
		var explosion = load("res://explosion.scn").instance()
		explosion.set_translation(get_translation())
		get_node("..").add_child(explosion)
		sound.play("die")
		queue_free()
		get_node("/root/Global").add_score(10)
		if randf() < 0.5:
			get_node("/root/Global").spawn_loot(get_translation())
	stunned = STUN_TIME

func _fixed_process(delta):
	var space = get_world().get_direct_space_state()
	var result = space.intersect_ray(get_translation()+Vector3(0,10,0), player.get_translation()+Vector3(0,10,0), [self])
	if not result.empty() and result["collider"] == player:
		walk_to = player.get_translation()
		walk_to.y = 0
		remember = MEMORY
	if remember > 0:
		look_at(walk_to, Vector3(0,1,0))
		if stunned <= 0:
			velocity = -get_global_transform().basis.z * SPEED
			var motion = velocity * delta
			motion = move(motion)
			if is_colliding():
				if get_collider() == player and anim.get_current_animation() != "attack":
					anim.play("attack")
				else:
					var n = get_collision_normal()
					motion = n.slide(motion)
					velocity = n.slide(velocity)
					move(motion)
		
		if not sound.is_voice_active(footsteps):
			footsteps = sound.play("footsteps")
	else:
		velocity = 0
		if sound.is_voice_active(footsteps):
			sound.stop_voice(footsteps)
			
	if attack and !player.dead and get_translation().distance_to(player.get_translation()) < 4:
		player.kill("Slaughtered by a brutal ogre.", self)
	
	attack = false



func _on_AnimationPlayer_finished():
	sound.play("attack")
	attack = true
