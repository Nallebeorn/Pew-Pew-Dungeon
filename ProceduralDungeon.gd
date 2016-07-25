# TOO many monsters seed: 1466977684

extends Spatial

var corridorColor1 = Color(0x323F72)
var corridorColor2 = Color(0xA8883C)

const SIZE = 50
const GRID_SIZE = 10
const GRID_HEIGHT = 20

const ROOM_MIN_SIZE = 6
const ROOM_MAX_SIZE = 20
const ROOM_MIN_HEIGHT = 1
const ROOM_MAX_HEIGHT = 3

var grid = {}

var level
const MAX_LEVEL = 10

const MONSTER_PROBABILITY = {
ogre = [.8, .8, .5, .3, .3, .3, .1, .1, .1, .1],
slime = [.1, .4, .4, .5, .6, .6, .7, .7, .7, .8],
gnome = [.0, .05,.1, .25, .4, .5, .6, .6, .7, .8],
turret = [.0, .0, .2, .3, .4, .5, .6, .6, .7, .8]
}

const TREASURE_PROBABILITY = 0.1

const MONSTER_MAX_NUMBER = [2, 3, 3, 4, 4, 4, 5, 5, 6, 6]

func create_room(x, y, xsize, ysize, height):
	for xx in range(x, x + xsize ):
		for yy in range(y, y + ysize):
			grid[Vector2(xx,yy)] = height
	x = x * GRID_SIZE
	y = y * GRID_SIZE
	xsize = xsize * GRID_SIZE
	ysize = ysize * GRID_SIZE

	var light
	light = OmniLight.new()
	light.set_translation(Vector3(x + xsize/2, height*GRID_SIZE-2, y + ysize/2))
	light.set_parameter(light.PARAM_ENERGY, rand_range(0.75, 1))
	light.set_parameter(light.PARAM_RADIUS, ROOM_MAX_SIZE * GRID_SIZE)
	add_child(light)
	
func create_horizontal_corridor(x1, x2, y, height):
	for x in range(x1, x2+1):
		if !grid.has(Vector2(x,y)) or grid[Vector2(x,y)] == 0:
			grid[Vector2(x,y)] = height

func create_vertical_corridor(y1, y2, x, height):
	for y in range(y1, y2+1):
		if !grid.has(Vector2(x,y)) or grid[Vector2(x,y)] == 0:
			grid[Vector2(x,y)] = height

func _ready():
	level = min(get_node("/root/Global").level, MAX_LEVEL)
	get_node("Label").add_message(str("===Level ",level,"==="))
	get_node("Score").update(level, get_node("/root/Global").score)
	if level == 1:
		var time = OS.get_unix_time()
		seed(time) # I don't use randomize() cuz I wanna be able to view the seed for debugging purposes
		prints("Seed:", time)
		var file = File.new()
		if file.file_exists("user://highscores.dat"):
			file.open("user://highscores.dat", file.READ)
			var hi_level = file.get_32()
			var hi_score = file.get_64()
			file.close()
			get_node("Label").add_message(str("Highscore: ", hi_level, "/", hi_score))
		else:
			get_node("Label").add_message("Welcome to the PEW-PEW DUNGEON, newcomer!").add_message("WASD or ARROW KEYS to walk").add_message("LEFT-CLICK to shoot. RIGHT-CLICK or press SPACE to jump").add_message("Find the exit. Steal the loot. Kill the monsters.").add_message("You can quit the game with Ctrl-Q, but your progress in the current dungeon will then be lost!")
	var wallScene = load("res://geometry/wall.scn")
	var floorScene = load("res://geometry/floor.scn")
	var ceilingScene = load("res://geometry/ceiling.scn")
	var roomScene = load("res://geometry/room.scn")
	
	get_node("Floor/CollisionShape").get_shape().set_extents(Vector3(SIZE * GRID_SIZE, 0.1, SIZE * GRID_SIZE))
	get_node("Floor").translate(Vector3((SIZE * GRID_SIZE)/2, -0.1, (SIZE * GRID_SIZE)/2))
	var floorTile
	for x in range(0, SIZE * GRID_SIZE + 100, 100):
		for y in range(0, SIZE * GRID_SIZE + 100, 100):
			floorTile = floorScene.instance()
			floorTile.set_translation(Vector3(x, 0, y))
			add_child(floorTile)
		
	for x in range(0, SIZE):
		for y in range(0, SIZE):
			grid[Vector2(x,y)] = 0
	var rect_list = []
	var allowedRect = Rect2(2,2, SIZE-2, SIZE-2)
	
	var monster_list = []
	for monster in MONSTER_PROBABILITY.keys():
		if MONSTER_PROBABILITY[monster][level-1] != 0:
			monster_list.append(monster)
	
	var attempts = 70
	while attempts:
		var x = randi() % SIZE
		var y = randi() % SIZE
		var width = round(rand_range(ROOM_MIN_SIZE, ROOM_MAX_SIZE))
		var height = round(rand_range(ROOM_MIN_SIZE, ROOM_MAX_SIZE))
		var ceilingHeight = round(rand_range(ROOM_MIN_HEIGHT, ROOM_MAX_HEIGHT))
		var room = Rect2(x, y, width+1, height+1)
		var fail = false
		if not allowedRect.encloses(room): # If it is outside the whole area the dungeon is supposed to be in
			fail = true
		else: # If it overlaps with a previous room
			for otherRoom in rect_list:
				if room.intersects(otherRoom):
					fail = true
		if not fail:
			create_room(x, y, width, height, ceilingHeight)
			
			var area = roomScene.instance()
			area.set_translation(Vector3(x * GRID_SIZE, 0, y * GRID_SIZE))
			area.translate(Vector3(GRID_SIZE*-.5, 0, GRID_SIZE*-.5))
			area.add_area(Vector3(x * GRID_SIZE, 0, y * GRID_SIZE), Vector3(width * GRID_SIZE, ceilingHeight * GRID_HEIGHT, height * GRID_SIZE))
			add_child(area)
			
			if rect_list.size() != 0: # If this is not the first room, create a corridor to the previous room. And monsters & stuff
				var prevRoom = rect_list[rect_list.size()-1]
				var prevX = round(rand_range(prevRoom.pos.x+2, prevRoom.pos.x + prevRoom.size.x-2))
				var prevY = round(rand_range(prevRoom.pos.y+2, prevRoom.pos.y + prevRoom.size.y-2))
				var newX = round(rand_range(room.pos.x+2, room.pos.x + room.size.x-2))
				var newY = round(rand_range(room.pos.y+2, room.pos.y + room.size.y-2))
				var corridorHeight = round(rand_range(ROOM_MIN_HEIGHT, ROOM_MAX_HEIGHT))
				var minX = min(prevX, newX)
				var minY = min(prevY, newY)
				var maxX = max(prevX, newX)
				var maxY = max(prevY, newY)
				if randf() > 0.5:
					create_vertical_corridor(minY, maxY, prevX, corridorHeight)
					create_horizontal_corridor(minX, maxX, newY, corridorHeight)
				else:
					create_horizontal_corridor(minX, maxX, prevY, corridorHeight)
					create_vertical_corridor(minY, maxY, newX, corridorHeight)
				
				var monsters = round(rand_range(1, MONSTER_MAX_NUMBER[min(level, MAX_LEVEL)-1]))
				var monster
				while monsters:
					monster = monster_list[randi() % monster_list.size()]
					if randf() <= MONSTER_PROBABILITY[monster][level-1]:
						var node = load("res://monsters/"+monster+".scn").instance()
						node.set_translation(Vector3(rand_range(x+1, x+width-1), 0, rand_range(y+1, y+height-1)) * GRID_SIZE)
						add_child(node)
						monsters -= 1
				
			else:
				get_node("Player").set_translation(Vector3(x + .5*width, 0, y + .5*height) * GRID_SIZE)
			rect_list.append(room)
		
			# LOOOOOT!!!! :D :D :D :D :D :D
			if randf() <= TREASURE_PROBABILITY:
				var treasure = load("res://upgrades/Safe.scn").instance()
				treasure.set_translation(Vector3(rand_range(x+1, x+width-1), 0, rand_range(y+1, y+height-1)) * GRID_SIZE)
				add_child(treasure)
		
		attempts -= 1
	
	for pos in grid.keys():
		# Create walls (they double as ceiling - I used separate ceiling nodes before, but that caused occasional crashes for some goddamn reason (though that turned out to be because Rasterizer/max_render_elements was to low... well, well), and I already has walls above the ceiling anyway, to make transitions between ceiling levels look good
		var create = true
		if grid[pos] == 0:
			# Don't create a new wall is the area is already surrounded by walls (doesn't apply to above-floor-level walls, they double as ceilings
			create = false
			for check in [Vector2(1,0), Vector2(0,1), Vector2(-1,0), Vector2(0,-1)]:
				if grid.has(pos + check) and grid[pos + check] != 0:
					create = true
		if create:
			var wall = wallScene.instance()
			wall.set_translation(Vector3(pos.x*GRID_SIZE, grid[pos] * GRID_HEIGHT, pos.y*GRID_SIZE))
			add_child(wall)
	
	# Create exit
	var exit_room = rect_list[round(rand_range(1, rect_list.size()-1))]
	var exit = load("res://exit.scn").instance()
	exit.set_translation(Vector3(exit_room.pos.x + .5*exit_room.size.x, 0, exit_room.pos.y + .5*exit_room.size.y) * GRID_SIZE)
	add_child(exit)
	
	set_process(true)

