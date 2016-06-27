
extends Area

var color1 = Color()
var color2 = Color()

func _ready():
	var colors = get_node("/root/ColorEffect").get_random_colors()
	color1 = colors[0]
	color2 = colors[1]

func add_area(pos, size):
	print(size)
	var visibility = get_node("VisibilityEnabler")
	visibility.set_aabb(visibility.get_aabb().merge(AABB(pos, size)))
	var shape = BoxShape.new()
	shape.set_extents(size * 0.5)
	add_shape(shape, Transform().translated(size*.5))

func _on_Room_body_enter( body ):
	if body.get_name() == "Player":
		get_node("/root/ColorEffect").change_colors(color1, color2)


func _on_Room_body_exit( body ):
	if body.get_name() == "Player":
		get_node("/root/ColorEffect").change_colors(get_node("..").corridorColor1, get_node("..").corridorColor2)
