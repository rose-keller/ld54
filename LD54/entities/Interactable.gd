extends Node

export var blocking = true
export var tag = ""

onready var game = $"/root/Game"

onready var current_coord = game.get_coord(self)
onready var target_coord = current_coord
var step_time = 0
var step_duration = 0.3
var is_blocked = false
var target_interactable
var removed_soon = false

func _ready():
	add_to_group("interactable")


func get_predicted_coord():
	if is_busy() and not is_blocked:
		return target_coord
	else:
		return current_coord


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

func trigger_interaction(actor):
	var interaction = get_interaction(actor)
	if interaction:
		interaction.trigger(actor)

func resolve_interaction(actor):
	var interaction = get_interaction(actor)
	if interaction:
		interaction.resolve(actor)

func will_remove(actor):
	var interaction = get_interaction(actor)
	return interaction and interaction.remove_actor


func start_step(step):
	step_time = 0
	current_coord = game.get_coord(self)
	target_coord = current_coord + step
	is_blocked = game.is_blocked(target_coord)
	
	removed_soon = false
	var entity = game.get_entity(target_coord)
	if entity and not entity.removed_soon:
		target_interactable = entity
		entity.start_interaction(self)
		removed_soon = entity.will_remove(self)
		if entity.blocks(self):
			is_blocked = true


func _process(delta):
	if is_busy():
		step_time += delta
		var d = step_time / step_duration
		if d <= 1:
			if d >= 0.5 and target_interactable and \
					target_interactable.has_method("trigger_interaction"):
				target_interactable.trigger_interaction(self)
			
			if is_blocked:
				d = (d if d <= 0.5 else 1 - d) / 2
			game.set_coord(self, lerp(current_coord, target_coord, d))

		else:
			if target_interactable and target_interactable.has_method("resolve_interaction"):
				target_interactable.resolve_interaction(self)
			target_interactable = null
			current_coord = game.get_coord(self)
			target_coord = current_coord
			removed_soon = false


func is_busy():
	return target_coord != current_coord
