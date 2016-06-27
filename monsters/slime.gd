
extends KinematicBody

onready var player = get_node("/root/World/Player")
onready var anim = get_node("AnimationPlayer")
var velocity
var walk_to = Vector3(0,0,1)
var SPEED = 25
const MEMORY = 5
var remember = 0
var footsteps = 0
var hp = 1
var stunned = 0
const STUN_TIME = 1
var attack = false
var size
const MAX_SIZE = 5

func _init():
	size = round(rand_range(2, MAX_SIZE))

func _ready():
	set_process(true)
	set_fixed_process(true)
	get_node("Sprite3D").set_scale(get_node("Sprite3D").get_scale() * Vector3(size, size, size))
	get_node("CollisionShape").set_scale(get_node("CollisionShape").get_scale() * Vector3(size, size, size))
	SPEED /= size
	hp = size
	
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
		if size <= 1:
			var explosion = load("res://explosion.scn").instance()
			explosion.set_translation(get_translation())
			get_node("..").add_child(explosion)
			queue_free()
			get_node("/root/Global").add_score(5)
			if randf() < 0.5:
				get_node("/root/Global").spawn_loot(get_translation())
			
		else:
			var slice = load("res://monsters/slime.scn").instance()
			slice.size = size - 1
			slice.set_translation(get_translation() + Vector3(randf()*10, 0, randf()*10))
			get_node("..").add_child(slice)
			slice.walk_to = walk_to
			slice.remember = MEMORY # This is mostly so they walk out if they're stuck in a wall
			slice = load("res://monsters/slime.scn").instance()
			slice.size = size - 1
			slice.set_translation(get_translation() + Vector3(randf()*10, 0, randf()*10))
			get_node("..").add_child(slice)
			slice.walk_to = walk_to
			slice.remember = MEMORY

			queue_free()
			get_node("/root/Global").add_score(1)
	stunned = STUN_TIME

func _fixed_process(delta):
	var space = get_world().get_direct_space_state()
	var result = space.intersect_ray(get_translation()+Vector3(0,15,0), player.get_translation()+Vector3(0,15,0), [self])
	if result.empty() or result["collider"] == player:
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
					motion = move(motion)
			
	if attack and !player.dead and (get_translation().distance_to(player.get_translation()) < 6 or (is_colliding() and get_collider() == player)):
		player.kill("Devoured by a carnivorous jelly.", self)
	
	attack = false



func _on_AnimationPlayer_finished():
	attack = true
