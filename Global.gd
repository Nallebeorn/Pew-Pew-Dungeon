
extends Node

var level

var player_speed 
var player_shoot_cooldown
var player_damage

var score

func reset_stats():
	player_speed = 25
	player_shoot_cooldown = 1
	player_damage = 0.5
	score = 0
	level = 1

func _ready():
	reset_stats()

func add_score(points):
	score += points
	get_node("/root/World/Score").update(level, score)

func spawn_loot(pos):
	var loot
	if randf() <= 0.5:
		loot = "Money"
	else:
		var upgrades = ["Damage", "Speed", "Gun"]
		loot = upgrades[round(rand_range(0, upgrades.size()-1))]
	var node = load("res://upgrades/"+loot+".scn").instance()
	node.set_translation(pos)
	get_node("/root/World").add_child(node)

func upgrade_stat(stat):
	var msg = "You can feel no change..."
	print("upgrade", stat)
	if stat == "speed":
		if player_speed < 60:
			player_speed += 5
			msg = "You feel swifter!"
	elif stat == "shoot_cooldown":
		if player_shoot_cooldown > 0.2:
			player_shoot_cooldown -= 0.1
			msg = "Your gun seems more responsive!"
	elif stat == "damage":
		print("damage!!")
		if player_damage < 3:
			player_damage += 0.5
			msg = "Your gun seems more powerful!"
	elif stat == "money":
		score += 500
		msg = "+500!"
	else:
		return
	get_node("/root/World/Player").update_stats()
	get_node("/root/World/Score").update(level, score)
	get_node("/root/World/Label").add_message(msg)