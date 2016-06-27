
extends Label

var text_queue = []

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func set_message(text):
	set_text(text)
	get_node("Timer").start()
	text_queue.append(text)
	return self

func add_message(text):
	if text_queue.empty():
		set_text(text)
	text_queue.append(text)
	get_node("Timer").start()
	return self

func _on_Timer_timeout():
	text_queue.pop_front()
	if text_queue.empty():
		set_text("")
	else:
		set_text(text_queue[0])
	get_node("Timer").start()
