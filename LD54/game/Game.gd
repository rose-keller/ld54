extends Node

var dirs = {"up": Vector2(0,-1), "left": Vector2(-1,0), "down": Vector2(0,1), "right": Vector2(1,0)}
var tile_size = 8

var current_coord
var target_coord
var has_target = false
var is_blocked = false
var target_interactable

var step_time = 0
var step_duration = 0.3

var hero
onready var floor_gen = $Floor

var level = 0
var resources = {"Heart": 3, "Gold": 0}


func _ready():
	randomize()
	descend()


func _input(event):
	if event.is_action_pressed("a"):
		descend()


func start_step():
	if not hero:
		return
	
	step_time = 0
	current_coord = get_coord(hero)
	target_coord = null
	for dir in dirs:
		if Input.is_action_pressed(dir):
			target_coord = current_coord + dirs[dir]
			has_target = true
			is_blocked = is_blocked(target_coord)
			
			target_interactable = get_entity(target_coord)
			if target_interactable and target_interactable.has_method("start_interaction"):
				target_interactable.start_interaction(hero)
			break


func get_entity(coord):
	if coord in floor_gen.entities_by_coord:
		return floor_gen.entities_by_coord[coord]


func remove(entity):
	if entity == hero:
		descend()
	else:
		floor_gen.entities_by_coord.erase(get_coord(entity))
		entity.queue_free()


func is_blocked(coord):
	if not floor_gen.is_in_bounds(coord):
		return true
	
	var entity = get_entity(coord)
	if entity and entity.has_method("blocks") and entity.blocks(hero):
		return true
	
	return false


func has_resource(resource):
	return resource in resources and resources[resource] > 0


func spend_resource(resource):
	if resource in resources:
		print("spending ",resource)
		resources[resource] = resources[resource] - 1
		update_ui()


func gain_resource(resource):
	if resource in resources:
		print("gaining ",resource)
		resources[resource] = resources[resource] + 1
		update_ui()


func descend():
	level += 1
	update_ui()
	hero = floor_gen.generate_floor()


func update_ui():
	var label = $UI/ResourceLabel
	label.text = "F:%-2d T:%-2d H:%-2d" % [level, resources["Gold"], resources["Heart"]]


func _process(delta):
	if has_target:
		step_time += delta
		var d = step_time / step_duration
		if d <= 1:
			if is_blocked:
				d = (d if d <= 0.5 else 1 - d) / 2
			set_coord(hero, lerp(current_coord, target_coord, d))
		else:
			if target_interactable and target_interactable.has_method("resolve_interaction"):
				target_interactable.resolve_interaction(hero)
			target_interactable = null
			has_target = false
	else:
		start_step()



func get_coord(entity):
	return (entity.position / tile_size).round()

func set_coord(entity, coord):
	entity.position = coord * tile_size
