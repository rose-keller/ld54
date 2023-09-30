extends Node2D

class_name Character

onready var sprite = $Sprite
onready var controller = $Controller
onready var tile_helper = $"/root/TileHelper"

onready var start_coord = get_coord()
onready var prev_coord = start_coord - Vector2(0,1)
onready var next_coord = start_coord

onready var planned_coord = start_coord
onready var planned_prev_coord = prev_coord
var is_blocked = false

var step_time = 0
var step_duration = 0.5
var step_counter = 0
var is_busy = false

var facing = "down"
var desired_velocity = Vector2.ZERO


func _ready():
	add_to_group("characters")


func get_coord():
	return tile_helper.get_coord(self)


func get_action():
	for child in get_children():
		if child.has_method("get_action"):
			return child.get_action()


func step():
	desired_velocity = Vector2.ZERO # until we are told to actually perform the step
	
	var action = get_action()
	var interactions = get_tree().get_nodes_in_group("interactions")
	for interaction in interactions:
		if interaction.try_interact(self, action):
			return
	
	var target_coord = get_target_coord(action)
	if target_coord and not target_coord.is_equal_approx(get_coord()):
		is_blocked = false
		prepare_next_step(target_coord)
		check_blocked_by_environment(get_node("%TileMap"))
		check_blocked_by_character(get_tree().get_nodes_in_group("characters"))
		start_step()


func try_interact():
	var interact_point = get_coord() + tile_helper.dirs[facing]
	var characters = get_tree().get_nodes_in_group("characters")
	for character in characters:
		if character.get_coord().is_equal_approx(interact_point):
			if character.receive_interaction(self):
				# todo - listen for a signal when the interaction is done?
				return true


func receive_interaction(character):
	for child in get_children():
		if child.has_method("try_start_interaction"):
			if child.try_start_interaction(character):
				return true


func get_target_coord(action):
	if action in tile_helper.dirs:
		return get_coord() + tile_helper.dirs[action]

	for child in get_children():
		if child.has_method("get_target_coord"):
			return child.get_target_coord()


func prepare_next_step(target_coord):
	var current_coord = get_coord()
	var step = target_coord - current_coord
	if step.x != 0 and step.y != 0:
		step = resolve_diagonal_step(step)
	
	start_coord = current_coord
	planned_coord = current_coord + step.normalized().round()
	planned_prev_coord = current_coord # planning to leave


func resolve_diagonal_step(step):
	if step_counter % 2:
		step.y = 0
	else:
		step.x = 0
	return step


func check_blocked_by_environment(tilemap):
	if not tile_helper.is_tile_walkable(tilemap, planned_coord):
		is_blocked = true
		return true


func check_blocked_by_character(characters):
	if is_follower():
		return false
	
	for character in characters:
		if character == self or not can_be_blocked_by_character(character):
			continue
		
		var coord
		if "is_blocked" in character and "planned_coord" in character \
				and not character.is_blocked and character.planned_coord:
			coord = character.planned_coord
		else:
			coord = tile_helper.pos_to_coord(character.position)
		
		if coord.is_equal_approx(planned_coord):
			is_blocked = true
			return true


func can_be_blocked_by_character(character):
	return not character.is_follower()


func is_follower():
	for child in get_children():
		if child.has_method("is_follower") and child.is_follower():
			return true
	return false


func start_step():
	step_time = 0
	step_counter += 1
	
	desired_velocity = planned_coord - start_coord
	if not desired_velocity.is_equal_approx(Vector2.ZERO):
		if abs(desired_velocity.x) > abs(desired_velocity.y):
			facing = "right" if desired_velocity.x > 0 else "left"
		else:
			facing = "down" if desired_velocity.y > 0 else "up"
	
	var current_coord = get_coord()
	if not planned_coord.is_equal_approx(current_coord) and not is_blocked:
		next_coord = planned_coord
		prev_coord = current_coord # now that we're actually leaving
	else:
		next_coord = current_coord
		planned_prev_coord = prev_coord # revert since we didn't move
	
	is_busy = planned_coord != current_coord


func finish_step():
	is_busy = false
	start_coord = null
	planned_coord = null
	next_coord = null
	

func _process(delta):
	if planned_coord:
		step_time += delta
		var d = step_time / step_duration
		if d <= 1:
			if next_coord and not next_coord.is_equal_approx(start_coord):
				tile_helper.set_coord(self, lerp(start_coord, next_coord, d))
		else:
			finish_step()
	
	if not is_busy:
		step()
	
	update_anim()


func update_anim():
	if is_zero_approx(desired_velocity.length_squared()):
		play_anim("stand")
	else:
		play_anim("walk")


func play_anim(action):
	var dir = facing
	
	if dir == "right":
		sprite.flip_h = true
		dir = "left"
	else:
		sprite.flip_h = false

	var anim = action + "_" + dir
	if sprite.frames.has_animation(anim):
		sprite.play(anim)
	else:
		sprite.play(action + "_down")
