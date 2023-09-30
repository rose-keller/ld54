extends Node

export var blocking = true
export var tag = ""

func blocks(actor):
	var interaction = get_interaction(actor)
	if interaction:
		return interaction.blocks()
	else:
		return blocking


func get_interaction(actor):
	if "tag" in actor:
		var interaction_node = get_node_or_null("Interaction_"+actor.tag)
		if interaction_node and interaction_node.can_interact():
			return interaction_node
	return null


func start_interaction(actor):
	var interaction = get_interaction(actor)
	if interaction:
		interaction.start(actor)


func resolve_interaction(actor):
	var interaction = get_interaction(actor)
	if interaction:
		interaction.resolve(actor)
