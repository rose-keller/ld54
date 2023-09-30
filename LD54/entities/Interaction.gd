extends Node

enum MovementType { Block, Overlap, Pushed }

export(MovementType) var movement
export(String, "", "Heart", "Key") var consumes
export(String, "", "Heart", "Key", "Gold") var gives
export var remove_self = false
export var remove_actor = false

onready var game = $"/root/Game"

func blocks():
	return movement != MovementType.Overlap


func can_interact():
	return not consumes or game.has_resource(consumes)


func start(actor):
	pass


func resolve(actor):
	game.spend_resource(consumes)
	game.gain_resource(gives)
	
	if remove_self:
		game.remove(get_parent())
		
	if remove_actor:
		game.remove(actor)
