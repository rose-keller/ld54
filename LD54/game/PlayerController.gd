extends Node

var buttons = ["a", "b"]
var button_queue = []

var dirs = ["up", "left", "down", "right"]
var dir_stack = []
var recently_pressed_dir = ""

func get_action():
	# prioritize buttons, then active dirs, then what dir was only just released
	var latest_input = get_next_button()
	if not latest_input:
		latest_input = get_latest_dir()
		if not latest_input:
			latest_input = recently_pressed_dir
	
	recently_pressed_dir = "" # only keep input in the queue for one step after it's pressed

	return latest_input
	

func _input(event):
	for input in dirs:
		if event.is_action_pressed(input):
			recently_pressed_dir = input
			dir_stack.append(input)
	
	for input in buttons:
		if event.is_action_released(input) and not input in button_queue:
			button_queue.append(input)


func get_next_button():
	if button_queue:
		return button_queue.pop_front()

func get_latest_dir():
	for i in range(dir_stack.size()-1, -1, -1):
		if not Input.is_action_pressed(dir_stack[i]):
			dir_stack.remove(i)
	
	return dir_stack.back() if dir_stack.size() else ""
