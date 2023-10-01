extends Node

var dirs = {"up": Vector2(0,-1), "left": Vector2(-1,0), "down": Vector2(0,1), "right": Vector2(1,0)}
var tile_size = 8

var step_time = 0
var step_duration = 0.3

onready var floor_gen = $Floor
onready var popups = get_tree().get_nodes_in_group("popups")

var fighter
var thief
var entering_heroes
var hero_order = []
var start_coords = []

var level = 1
var stats = {"Gold": 0,
			"MaxGold": 5,
			"Heart_Fighter": 0, "MaxHealth_Fighter": 6,
			"Heart_Thief": 0, "MaxHealth_Thief": 2}


func _ready():
	randomize()
	restart()

func win():
	stats.MaxHealth_Fighter += 2
	stats.MaxHealth_Thief += 2
	stats.MaxGold += 10


func restart():
	for popup in popups:
		popup.visible = false
	
	level = 0
	stats.Heart_Fighter = stats.MaxHealth_Fighter
	stats.Heart_Thief = stats.MaxHealth_Thief
	stats.Gold = 0
	update_ui()
	descend()


func descend():
	var hero_order = []
	if stats.Heart_Fighter > 0:
		hero_order.append("HeroFighter")
	if stats.Heart_Thief > 0:
		hero_order.append("HeroThief")
		
	if not hero_order:
		$UI/HealthMessage.visible = true
		return
	
	level += 1
	update_ui()
	
	entering_heroes = floor_gen.generate_floor(hero_order, start_coords)
	for hero in entering_heroes:
		if "Fighter" in hero.name:
			fighter = hero
		if "Thief" in hero.name:
			thief = hero
		hero.add_to_group("heroes")
		hero.connect("finish_step", self, "update_hero_entrances")
	var first_hero = entering_heroes.pop_front()
	first_hero.visible = true

	hero_order.clear()
	start_coords.clear()
	
	yield(get_tree(), "idle_frame")
	update_hero_entrances()


func update_hero_entrances():
	for hero in entering_heroes:
		print("entering: ", hero, get_overlapping_hero(hero))
		if get_overlapping_hero(hero):
			hero.visible = false
		else:
			hero.visible = true
			entering_heroes.remove(entering_heroes.find(hero))
	

func _input(event):
	for popup in popups:
		if popup.visible: return
	
	if event.is_action_released("accept") or event.is_action_released("cancel"):
		$UI/EscapeMessage.visible = true
#	elif event.is_action_pressed("b"):
#		switch_hero()


#func switch_hero():
#	update_hero_entrances()
#	var heroes = get_tree().get_nodes_in_group("heroes")
#	if heroes:
#		var index = heroes.find(hero)
#		hero = heroes[(index + 1) % heroes.size()]


func _process(delta):
	for popup in popups:
		if popup.visible: return
	
	var heroes = get_tree().get_nodes_in_group("heroes")
	for hero in heroes:
		if hero.visible and not hero.is_busy():
			for dir in dirs:
				if Input.is_action_pressed(dir if ("Fighter" in hero.name) else dir + "2"):
					hero.start_step(dirs[dir])


func get_entity(coord):
	var entities = get_tree().get_nodes_in_group("interactable")
	for entity in entities:
		if get_coord(entity) == coord and entity.visible:
			return entity


func get_overlapping_hero(actor):
	var entities = get_tree().get_nodes_in_group("heroes")
	for entity in entities:
		if entity != actor and get_coord(entity) == get_coord(actor):
			return entity


func remove(entity):
	entity.visible = false
	entity.dead = true
	
	if entity.is_in_group("heroes"):
		print("Removing: ",entity.name, get_coord(entity))
		hero_order.append(entity.filename)
		start_coords.append(get_coord(entity))
		
		entity.visible = false
		entity.dead = true
		var heroes = get_tree().get_nodes_in_group("heroes")
		for hero in heroes:
			if not hero.dead:
				return
		descend()


func is_blocked(coord):
	if not floor_gen.is_in_bounds(coord):
		return true
	return false


func try_push(actor, target):
	var actor_coord = get_coord(actor)
	var target_coord = get_coord(target)
	var step = target_coord - actor_coord
	#var corner_step = floor_gen.try_get_corner_step(target_coord, step)
	target.start_step(step)#corner_step if corner_step else step)


func get_resource_key(actor, resource):
	if resource in stats:
		return resource
	if actor and "tags" in actor:
		for tag in actor.tags:
			var key = resource + "_" + tag
			if key in stats:
				return key
	return null


func has_resource(actor, resource, amount):
	return true
#	var key = get_resource_key(actor, resource)
#	return key and stats[key] >= amount


func spend_resource(actor, resource, amount):
	var key = get_resource_key(actor, resource)
	print("spend resource %s for %s => %s" % [resource, actor, key])
	if key:
		print("-",amount," ",key)
		stats[key] -= amount
		update_ui()
		
		if resource == "Heart" and stats[key] <= 0:
			if stats.Heart_Fighter <= 0 and stats.Heart_Thief <= 0:
				$UI/HealthMessage.visible = true
			remove(actor)


func gain_resource(actor, resource, amount):
	var key = get_resource_key(actor, resource)
	if key:
		print("+",amount," ",key)
		stats[key] += amount
		
		stats.Heart_Fighter = min(stats.Heart_Fighter, stats.MaxHealth_Fighter)
		stats.Heart_Thief = min(stats.Heart_Thief, stats.MaxHealth_Thief)
		stats.Gold = min(stats.Gold, stats.MaxGold)
		
		update_ui()
		
		if stats.Gold >= stats.MaxGold:
			$UI/TreasureMessage.visible = true
			win()


func update_ui():
	$UI/FighterUI/HealthBar.set(stats.Heart_Fighter, stats.MaxHealth_Fighter)
	$UI/ThiefUI/HealthBar.set(stats.Heart_Thief, stats.MaxHealth_Thief)
	$UI/ResourceLabel.text = "Treasure: %d/%d" % [stats.Gold, stats.MaxGold]


func get_coord(entity):
	return (entity.position / tile_size).round()

func set_coord(entity, coord):
	entity.position = coord * tile_size


func _on_SurfaceButton_pressed():
	restart()


func _on_CancelButton_pressed():
	$UI/EscapeMessage.visible = false
