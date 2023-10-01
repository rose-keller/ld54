extends Node

class_name Interactable

signal finish_step

export var blocking = true
export(Array, String) var tags = []

onready var game = $"/root/Game"

onready var current_coord = game.get_coord(self)
onready var target_coord = current_coord
var step_time = 0
var step_duration = 0.3
var is_blocked = false
var target_interactable
var removed_soon = false
var dead = false

var remove_on_bounce = false

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
	if "tags" in actor:
		for tag in actor.tags:
			var interaction_node = get_node_or_null("Interaction_"+tag)
			if interaction_node and interaction_node.can_interact(actor):
				return interaction_node
	return null


func start_interaction(actor):
	var interaction = get_interaction(actor)
	if interaction:
		interaction.start(actor)
	return interaction

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


func start_step(step, try_remove_on_bounce = false):
	step_time = 0
	current_coord = game.get_coord(self)
	target_coord = current_coord + step
	is_blocked = game.is_blocked(target_coord)
	
	# pop whoever's moving to the front
	get_parent().move_child(self, get_parent().get_child_count() - 1)
	
	removed_soon = false
	var entity = game.get_entity(target_coord)
	var has_interaction = false
	if entity and entity.visible and not entity.removed_soon:
		target_interactable = entity
		has_interaction = entity.start_interaction(self)
		removed_soon = entity.will_remove(self)
		if entity.blocks(self):
			is_blocked = true

	print("remove on bounce? %s, is_blocked: %s, interactable: %s" % [try_remove_on_bounce, is_blocked, has_interaction])
	remove_on_bounce = try_remove_on_bounce and is_blocked and not has_interaction


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
			if not is_blocked:
				emit_signal("finish_step")
			
			if target_interactable and target_interactable.has_method("resolve_interaction"):
				target_interactable.resolve_interaction(self)
			target_interactable = null
			current_coord = game.get_coord(self)
			target_coord = current_coord
			removed_soon = false
			
			if remove_on_bounce:
				game.remove(self)


func is_busy():
	return target_coord != current_coord


func take_damage():
	if has_node("AnimationPlayer"):
		$AnimationPlayer.play("damage")
		for i in range(2):
			$AnimationPlayer.queue("damage")
