extends Node2D

export var floor_width = 4
export var floor_height = 4
var tilesize = 8

var entrance_res = "Marker"
var exit_res = "Ladder"
var obstacle_res = {"Slime": 2, "Ball": 2, "Spikes": 1, "Hole": 0}
var treasure_res = {"Chest": 3, "Heart": 0}

onready var game = $"/root/Game"
onready var tilemap = $TileMap
var entities_by_coord = {}
var unused_sides = []
var heroes = []

var entrance_coord = Vector2(0, -1)
var exit_coord = Vector2(floor_width - 1, floor_height)

func generate_floor(hero_order, start_coords):
	print("-- generate floor -- ",hero_order)
	for entity in $Entities.get_children():
		entity.queue_free()
	heroes.clear()
	
	generate_tiles(start_coords)
	
	unused_sides = range(4)
	generate_heroes(hero_order, start_coords)
	generate_exits()
	
	generate_entities(treasure_res, randi_range(1, 2), true)#randi_range(1, 2))
	generate_entities({"Rock":1}, randi_range(1, 1))#randi_range(1, 2))
	generate_entities({"Hole":1}, 1)#randi_range(1, 2))
	generate_entities(obstacle_res, randi_range(4, 5), true) #randi_range(3, 4))
	
	entities_by_coord.clear()

	for hero in heroes:
		$Entities.move_child(hero, $Entities.get_child_count())
	return heroes


func generate_heroes(hero_order, start_coords):
	for i in range(hero_order.size()):
		var side = unused_sides.pop_at(randi() % unused_sides.size())
		var coord = get_coord_on_side(side)
		var hero = spawn(hero_order[i], coord)#start_coords[i])
		heroes.append(hero)


func generate_exits():
	var exit_side = unused_sides.pop_at(randi() % unused_sides.size())
	for n in range(100):
		var exit_coord = get_coord_on_side(exit_side)
		if not exit_coord in entities_by_coord:
			spawn(exit_res, exit_coord)
			break


func generate_entities(resource_weights, count, avoid_repeats = false):
	var bucket = []
	for n in range(count):
		if not bucket:
			if not resource_weights:
				return
			for key in resource_weights:
				for m in (resource_weights[key]):
					bucket.append(key)
		
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
	var path = name if name.begins_with("res:") else "res://entities/%s.tscn" % name
	var resource = load(path)
	var entity = resource.instance()
	$Entities.add_child(entity)
	entity.add_to_group("entities")
	entities_by_coord[coord] = entity
	entity.position = coord * tilesize
	return entity


func generate_tiles(start_coords):
	tilemap.clear()
#	for x in range(-1, floor_width + 1, 1):
#		tilemap.set_cell(x, -1, 2)
#		tilemap.set_cell(x, floor_height, 2)
#	for y in range(floor_height):
#		tilemap.set_cell(-1, y, 2)
#		tilemap.set_cell(floor_width, y, 2)

	if start_coords:
		for coord in start_coords:
			tilemap.set_cellv(coord, get_cell(coord.x, coord.y))
	#tilemap.set_cellv(entrance_coord, get_cell(entrance_coord.x, entrance_coord.y))
	#tilemap.set_cellv(exit_coord, get_cell(exit_coord.x, exit_coord.y))
	
	for x in range(floor_width):
		for y in range(floor_height):
			tilemap.set_cell(x, y, get_cell(x, y))

func get_cell(x, y):
	if int(x + y) % 2:
		return 1
	else:
		return 3


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
