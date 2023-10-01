extends Node2D

func show_equipment(equipment):
	for child in get_children():
		child.visible = child.name in equipment
