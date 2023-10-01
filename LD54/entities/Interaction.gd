extends Node

enum MovementType { Block, Overlap, Pushed }

export(MovementType) var movement
export(String, "", "Heart", "Gold") var consumes
export var consume_amount = 1
export(String, "", "Heart", "Gold", "MaxHealth", "MaxGold") var gives
export var give_amount = 1
export var give_equipment = false
export var remove_self = false
export var remove_actor = false

onready var game = $"/root/Game"
var has_triggered = false

func blocks():
	return movement != MovementType.Overlap


func can_interact(actor):
	return not consumes or game.has_resource(actor, consumes, consume_amount)


func start(actor):
	has_triggered = false


func trigger(actor):
	if not has_triggered:
		if movement == MovementType.Pushed:
			game.try_push(actor, get_parent())
		has_triggered = true


func resolve(actor):
	var parent = get_parent()
	game.spend_resource(actor, consumes, consume_amount, parent)
	game.gain_resource(actor, gives, give_amount, parent)
	
	if give_equipment:
		game.equip(parent.name)
	
	if remove_self:
		game.remove(parent)
		
	if remove_actor:
		game.remove(actor)
	
	if "use_count" in parent:
		parent.use_count += 1
