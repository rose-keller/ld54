extends Node

enum MovementType { Block, Overlap, Pushed }

export(MovementType) var movement
export(String, "", "Heart", "Key") var consumes
export(String, "", "Heart", "Key", "Gold") var gives
export var remove_self = false
export var remove_actor = false

onready var game = $"/root/Game"
var has_triggered = false

func blocks():
	return movement != MovementType.Overlap


func can_interact():
	return not consumes or game.has_resource(consumes)


func start(actor):
	has_triggered = false


func trigger(actor):
	if not has_triggered:
		if movement == MovementType.Pushed:
			game.try_push(actor, get_parent())
		has_triggered = true


func resolve(actor):
	game.spend_resource(consumes)
	game.gain_resource(gives)
	
	if remove_self:
		game.remove(get_parent())
		
	if remove_actor:
		game.remove(actor)
