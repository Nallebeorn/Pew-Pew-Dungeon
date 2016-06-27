extends Node

var mesh_materials = {}
var billboard_materials = {}

var _color1 = Color(0,0,0)
var _color2 = Color(1,1,1)
var _oldColor1 = _color1
var _oldColor2 = _color2
var _targetColor1 = _color1
var _targetColor2 = _color2
var _materials = {}
var _tweener = Tween.new()

func change_colors_random():
	var colors = get_random_colors()
	change_colors(colors[0], colors[1])
	return colors

func get_random_colors():
	# Disclaimer: I know nothing about color theory,
	# there are probably much better algorithms
	# to generate a random two-color palette
	var hue1 = randf() * 360 # Pick random hue
	var hue2 = fmod(hue1 + 120 * ((randi() % 2) * 2 - 1), 360) # Pick one of its two triadic colors
	# Pick random saturations
	var saturation1 = rand_range(0.3, 1)
	var saturation2 = rand_range(0.3, 1)
	# And values
	var value1 = rand_range(0.45, 0.85)
	var value2 = rand_range(0.45, 0.85)
	
	# Convert to rgb and return array with the two colors
	var colors = [null,null]
	colors[0] = hsv2rgb([hue1, saturation1, value1])
	colors[1] = hsv2rgb([hue2, saturation2, value2])
	return colors
	
func hsv2rgb(c): # Credits to mateusak for this
    var r = 0; var g = 0; var b = 0

    if (c[1] == 0 || c[2] == 0):
        r = c[2]; g = c[2]; b = c[2];
    else:
        var hf = c[0] / 60.0
        var i = floor(hf)
        var f = hf - i
        var p = c[2] * (1 - c[1])
        var q = c[2] * (1 - c[1] * f)
        var t = c[2] * (1 - c[1] * (1 - f))

        if (i == 0):
            r = c[2]; g = t; b = p
        elif (i == 1):
            r = q; g = c[2]; b = p
        elif (i == 2):
            r = p; g = c[2]; b = t      
        elif (i == 3):
            r = p; g = q; b = c[2]
        elif (i == 4):
            r = t; g = p; b = c[2]  
        else:
            r = c[2]; g = p; b = q              

    return Color(r, g, b)

func change_colors(replaceBlack, replaceWhite):
	_oldColor1 = _color1
	_oldColor2 = _color2
	_targetColor1 = replaceBlack
	_targetColor2 = replaceWhite
	_tweener.remove_all()
	_tweener.interpolate_method(self, "_lerp_colors", 0, 1, 0.5, _tweener.TRANS_SINE, _tweener.EASE_IN_OUT)
	_tweener.start()
	
func _lerp_colors(v):
	_color1 = _oldColor1.linear_interpolate(_targetColor1, v)
	_color2 = _oldColor2.linear_interpolate(_targetColor2, v)
	_updateAll()
	
func register(node):
	var mat
	if node extends CanvasItem:
		mat = node.get_material()
	elif node extends GeometryInstance:
		mat = node.get_material_override()
	else:
		print(node.get_name(), " is not a node with a material, stupid.", node)
		return
	_materials[node.get_path()] = mat
	_updateMaterial(mat)
	
func unregister(node):
	_materials.erase(node.get_path())

func _init():
	add_child(_tweener, true)
	change_colors_random()

func _updateAll():
	for node in _materials.keys():
		if has_node(node):
			_updateMaterial(_materials[node])
		else:
			_materials.erase(node)
			
func _updateMaterial(mat):
	mat.set_shader_param("Color1", _color1)
	mat.set_shader_param("Color2", _color2)