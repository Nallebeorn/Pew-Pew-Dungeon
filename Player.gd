 # Based on Gokudumatic's FPS Tutorial. Huge thanks to him!
# (github.com/gokudomatic/godot/tree/master/demos/3d/kinematic_fps)

extends KinematicBody

var mouse_sensitivity = 0.3
var yaw = 0
var pitch = 0
var velocity = Vector3()
var is_moving = false
var on_floor = false
var shoot_timer = 0
var footsteps = 0
var dead = false
var killer

const FLY_SPEED = 2000
const FLY_ACC = 4

var WALK_MAXSPEED = 30
var SHOOT_TIMEOUT = 0.6

const ACC = 2
const DEACC = 4
const GRAVITY = 70
const JUMP_SPEED = 40
const MAX_SLOPE_ANGLE = deg2rad(40)
const GUN_TIP = 6

func kill(message, killer):
	print("dying")
	get_node("SamplePlayer").play("death")
	dead = true
	self.killer = killer
	set_fixed_process(false)
	get_node("AnimationPlayer").play("die")
	get_node("/root/World/Label").set_message("===GAME OVER===").add_message(message).add_message("Randomly mash your keyboard in frustration to continue")
	var file = File.new()
	file.open("user://highscores.dat", file.READ_WRITE)
	var hi_level = file.get_32()
	var hi_score = file.get_64()
	file.seek(0)
	file.store_32(max(get_node("/root/Global").level, hi_level))
	file.store_64(max(get_node("/root/Global").score, hi_score))
	file.close()
	
func _input(event):
	if not dead:
		if event.type == InputEvent.MOUSE_MOTION:
			yaw = fmod(yaw - event.relative_x * mouse_sensitivity, 360)
			pitch = clamp(pitch - event.relative_y, -80, 70)
			get_node("Yaw").set_rotation(Vector3(0, deg2rad(yaw), 0))
			get_node("Yaw/Camera").set_rotation(Vector3(deg2rad(pitch), 0, 0))
		elif event.is_action_pressed("toggle_mouse"):
			if (Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED):
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			get_tree().set_input_as_handled()
	elif not get_node("AnimationPlayer").is_playing():
		if (event.type == InputEvent.KEY or event.type == InputEvent.MOUSE_BUTTON) and event.pressed:
			get_node("/root/Global").reset_stats()
			get_tree().reload_current_scene()

func _fixed_process(delta):
	walk(delta)
	if shoot_timer > 0:
		shoot_timer -= delta
	else:
		if Input.is_action_pressed("shoot"):
			var bullet = load("res://bullet.scn").instance()
			var screenPos = get_viewport().get_rect().size*.5
			bullet.dir = get_node("Yaw/Camera").project_ray_normal(screenPos)
			bullet.set_translation(get_node("Yaw/Camera").project_ray_origin(screenPos) + bullet.dir * GUN_TIP)
			get_node("..").add_child(bullet)
			shoot_timer = SHOOT_TIMEOUT
			get_node("SamplePlayer").play("shoot")

func _process(delta):
	if dead:
		get_node("Yaw/Camera").look_at(killer.get_translation() + Vector3(0, 5, 0), Vector3(0,1,0))

func _ready():
	set_process_input(true)
	set_fixed_process(true)
	set_process(true)
	update_stats()

func update_stats():
	var g = get_node("/root/Global")
	WALK_MAXSPEED = g.player_speed
	SHOOT_TIMEOUT = g.player_shoot_cooldown
	
func _enter_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _exit_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func flash():
	get_node("Flash").set_hidden(false)
	get_node("Flash").get_node("Timer").start()

func walk(delta):
	var ray = get_node("Ray")
	
	var aim = get_node("Yaw/Camera").get_global_transform().basis
	var dir = Vector3()
	if Input.is_action_pressed("move_forwards"):
		dir -= aim[2]
	if Input.is_action_pressed("move_backwards"):
		dir += aim[2]
	if Input.is_action_pressed("strafe_left"):
		dir -= aim[0]
	if Input.is_action_pressed("strafe_right"):
		dir += aim[0]
	dir.y = 0
	dir = dir.normalized()
	
	is_moving = dir.length() > 0
	var is_ray_colliding = ray.is_colliding()
	if not on_floor and is_ray_colliding:
		set_translation(ray.get_collision_point())
		on_floor = true
		get_node("SamplePlayer").play("land")
	elif on_floor and not is_ray_colliding:
		on_floor = false
	
	var acc = ACC
	if not is_moving:
		acc = DEACC
	
	if on_floor:
		if Input.is_action_pressed("jump"):
			velocity.y = JUMP_SPEED;
			get_node("SamplePlayer").play("jump")
		else:
			var n = ray.get_collision_normal()
			velocity = velocity - velocity.dot(n)*n
			if acos(n.dot(Vector3(0,1,0))) > MAX_SLOPE_ANGLE:
				velocity.y -= GRAVITY * delta
	else:
		velocity.y -= GRAVITY * delta
	
	var target = dir * WALK_MAXSPEED
	
	var hvel = velocity
	hvel.y = 0
	hvel = hvel.linear_interpolate(target, acc*delta)
	velocity.x = hvel.x
	velocity.z = hvel.z
	
	var motion = velocity * delta
	motion = move(motion)
	
	if motion.length() > 0 and is_colliding():
		var n = get_collision_normal()
		motion = n.slide(motion)
		velocity = n.slide(velocity)
		motion = move(motion)
	if get_node("SamplePlayer").is_active() and (!is_moving or !on_floor) and get_node("SamplePlayer").is_voice_active(footsteps):
		get_node("SamplePlayer").stop(footsteps)
	elif is_moving and on_floor and !get_node("SamplePlayer").is_voice_active(footsteps):
		footsteps = get_node("SamplePlayer").play("footsteps")
	
func fly(delta):
	var aim = get_node("Yaw/Camera").get_global_transform().basis
	var dir = Vector3()
	if Input.is_action_pressed("move_forwards"):
		dir -= aim[2]
	if Input.is_action_pressed("move_backwards"):
		dir += aim[2]
	if Input.is_action_pressed("strafe_left"):
		dir -= aim[0]
	if Input.is_action_pressed("strafe_right"):
		dir += aim[0]
		
	dir = dir.normalized()
	var target = dir * FLY_SPEED
	velocity = Vector3().linear_interpolate(target, FLY_ACC*delta)
	
	var motion = velocity * delta
	move(motion)
	var org_velocity = velocity
	var attempts = 4
	
	while attempts and is_colliding():
		var n = get_collision_normal()
		motion = n.slide(motion)
		velocity = n.slide(velocity)
		if org_velocity.dot(velocity) > 0:
			motion = move(motion)
			if motion.length() < 0.001:
				break
		attempts -= 1
		
func _on_AnimationPlayer_finished():
	pass
