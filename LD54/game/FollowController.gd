extends Node

export(NodePath) var target_node_path
onready var target_node = get_node(target_node_path) if target_node_path else null

func get_target_coord():
	if target_node:
		if "planned_prev_coord" in target_node:
			return target_node.planned_prev_coord
		elif target_node.has_method("get_coord"):
			return target_node.get_coord()
	
	return null

func is_follower():
	return true
