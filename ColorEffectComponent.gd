extends Node

export(Texture) var texture = null
export(bool) var billboard = false
export(bool) var unshaded = false

func _ready():
	var owner = get_node("..")
	if texture == null and owner.get("texture") != null:
		texture = owner.texture;
	var material_list
	if billboard:
		material_list = get_node("/root/ColorEffect").billboard_materials
	else:
		material_list = get_node("/root/ColorEffect").mesh_materials
	if material_list.has(texture):
		owner.set_material_override(material_list[texture])
	else:
		var mat = ShaderMaterial.new()
		mat.set_shader_param("Texture", texture)
		mat.set_flag(mat.FLAG_UNSHADED, unshaded)
		if billboard:
			mat.set_shader(load("res://shader_alpha.shd"))
			mat.set_flag(mat.FLAG_INVERT_FACES, true)
		else:
			mat.set_shader(load("res://shader_opaque.shd"))
		owner.set_material_override(mat)
		material_list[texture] = mat # Reuse materials if they use the same textures, anyway
	if owner.has_node("VisibilityNotifier"):
		owner.get_node("VisibilityNotifier").connect("enter_screen", self, "_on_enter_screen", [owner])
		owner.get_node("VisibilityNotifier").connect("exit_screen", self, "_on_exit_screen", [owner])
	else:
		get_node("/root/ColorEffect").register(owner)

func _on_enter_screen(node):
	get_node("/root/ColorEffect").register(node)

func _on_exit_screen(node):
	if is_inside_tree():
		get_node("/root/ColorEffect").unregister(node)


