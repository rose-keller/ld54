extends Node

var dirs = {"up": Vector2(0,-1), "left": Vector2(-1,0), "down": Vector2(0,1), "right": Vector2(1,0)}
var tile_size = 8

var step_time = 0
var step_duration = 0.3

onready var floor_gen = $Floor
var hero
var level = 1
var stats = {"Heart": 3, "Gold": 0, "MaxHealth": 3, "MaxGold": 5}


func _ready():
	randomize()
	hero = floor_gen.generate_floor(null)
	update_ui()


func restart():
	$UI/TreasureMessage.visible = false
	$UI/HealthMessage.visible = false
	level = 0
	descend()
	stats.MaxHealth += 1
	stats.MaxGold += 5
	stats.Heart = stats.MaxHealth
	stats.Gold = 0
	update_ui()


func _input(event):
	if event.is_action_pressed("a"):
		descend()


func _process(delta):
	if hero and not hero.is_busy():
		for dir in dirs:
			if Input.is_action_pressed(dir):
				hero.start_step(dirs[dir])


func get_entity(coord):
	var entities = get_tree().get_nodes_in_group("interactable")
	for entity in entities:
		if get_coord(entity) == coord:
			return entity


func remove(entity):
	if entity == hero:
		descend()
	else:
		entity.queue_free()


func is_blocked(coord):
	if not floor_gen.is_in_bounds(coord):
		return true
	return false


func try_push(actor, target):
	var actor_coord = get_coord(actor)
	var target_coord = get_coord(target)
	var step = target_coord - actor_coord
	var corner_step = floor_gen.try_get_corner_step(target_coord, step)
	target.start_step(corner_step if corner_step else step)


func has_resource(resource):
	return resource in stats and stats[resource] > 0


func spend_resource(resource):
	if resource in stats:
		print("spending ",resource)
		stats[resource] -= 1
		update_ui()
		
		if stats.Heart <= 0:
			$UI/HealthMessage.visible = true


func gain_resource(resource):
	if resource in stats:
		print("gaining ",resource)
		stats[resource] += 1
		
		stats.Heart = min(stats.Heart, stats.MaxHealth)
		stats.Gold = min(stats.Gold, stats.MaxGold)
		
		update_ui()
		
		if stats.Gold >= stats.MaxGold:
			$UI/TreasureMessage.visible = true


func descend():
	level += 1
	update_ui()
	hero = floor_gen.generate_floor(get_coord(hero) if hero else null)


func update_ui():
	$UI/HealthBar.set(stats.Heart, stats.MaxHealth)
	$UI/ResourceLabel.text = "Treasure: %d/%d" % [stats.Gold, stats.MaxGold]


func get_coord(entity):
	return (entity.position / tile_size).round()

func set_coord(entity, coord):
	entity.position = coord * tile_size


func _on_SurfaceButton_pressed():
	restart()
