extends Node2D

export var floor_width = 4
export var floor_height = 3
var tilesize = 8

var hero_res = "Hero1"
var entrance_res = "Marker"
var exit_res = "Ladder"
var obstacle_res = {"Slime": 2, "Ball": 2, "Hole": 1}
var treasure_res = {"Chest": 3, "Heart": 1}

onready var game = $"/root/Game"
onready var tilemap = $TileMap
var entities_by_coord = {}
var hero
var prev_exit_coord

func generate_floor(exit_coord):
	prev_exit_coord = exit_coord
	
	for entity in $Entities.get_children():
		entity.queue_free()
	
	generate_tiles()
	generate_exits()
	generate_entities(treasure_res, 1, true)#randi_range(1, 2))
	generate_entities({"Rock":1}, 1)#randi_range(1, 2))
	generate_entities(obstacle_res, 3, true) #randi_range(3, 4))
	
	entities_by_coord.clear()

	$Entities.move_child(hero, $Entities.get_child_count())
	return hero


func generate_exits():
	var entrance_coord
	var entrance_side
	if prev_exit_coord:
		entrance_coord = prev_exit_coord
		entrance_side = get_side_of_coord(entrance_coord)
	else:
		entrance_side = randi() % 4
		entrance_coord = get_coord_on_side(entrance_side)
	
	#spawn(entrance_res, entrance_coord)
	hero = spawn(hero_res, entrance_coord)

	var exit_side = (entrance_side + 2) % 4
	var exit_coord = get_coord_on_side(exit_side)
	spawn(exit_res, exit_coord)


func generate_entities(resource_weights, count, avoid_repeats = false):
	var bucket = []
	for n in range(count):
		if not bucket:
			for key in resource_weights:
				for m in (resource_weights[key]):
					bucket.append(key)
			print(bucket)
		
		var i = randi() % bucket.size()
		var resource = bucket[i]
		if avoid_repeats:
			bucket.pop_at(i)
		
		while entities_by_coord.size() < floor_width * floor_height:
			var coord = Vector2(randi() % floor_width, randi() % floor_height)
			if not coord in entities_by_coord:
				spawn(resource, coord)
				break


func spawn(name, coord):
	var resource = load("res://entities/%s.tscn" % name)
	var entity = resource.instance()
	$Entities.add_child(entity)
	entity.add_to_group("entities")
	entities_by_coord[coord] = entity
	entity.position = coord * tilesize
	return entity


func generate_tiles():
	tilemap.clear()
#	for x in range(-1, floor_width + 1, 1):
#		tilemap.set_cell(x, -1, 2)
#		tilemap.set_cell(x, floor_height, 2)
#	for y in range(floor_height):
#		tilemap.set_cell(-1, y, 2)
#		tilemap.set_cell(floor_width, y, 2)
	
	for x in range(floor_width):
		for y in range(floor_height):
			tilemap.set_cell(x, y, 1 if (x + y) % 2 else 3)


func is_in_bounds(coord):
	return coord.x >= 0 and coord.x < floor_width \
		and coord.y >= 0 and coord.y < floor_height


func get_coord_on_side(side):
	if side % 2:
		return Vector2(0 if side > 2 else floor_width - 1, randi() % floor_height)
	else:
		return Vector2(randi() % floor_width, 0 if side < 2 else floor_height - 1)

func get_side_of_coord(coord):
	var sides = []
	if coord.y == 0:
		sides.append(0)
	elif coord.y == floor_height - 1:
		sides.append(2)
	
	if coord.x == 0:
		sides.append(3)
	elif coord.x == floor_width - 1:
		sides.append(1)
	
	print(coord, sides)
	if sides:
		return sides[randi() % sides.size()]
	else:
		return randi() % 4

func try_get_corner_step(coord, step):
	var mx = floor_width - 1
	var my = floor_height - 1
	if coord == Vector2(0,0) or coord == Vector2(mx, my):
		return Vector2(-step.y, -step.x)
	elif coord == Vector2(0, my) or coord == Vector2(mx, 0):
		return Vector2(step.y, step.x)
	return null

func randi_range(low, high):
	return randi() % (high + 1 - low) + low
