extends Node2D

export var floor_width = 3
export var floor_height = 3
var tilesize = 8

export(Resource) var hero_resource
export(Resource) var exit
export(Resource) var entrance
export(Array, Resource) var obstacles = []
export(Array, Resource) var treasures = []

onready var game = $"/root/Game"
onready var tilemap = $TileMap
var entities_by_coord = {}
var entrance_coord
var hero


func generate_floor():
	generate_tiles()
	
	for c in entities_by_coord:
		remove_child(entities_by_coord[c])
		entities_by_coord[c].queue_free()
	entities_by_coord.clear()
	
	if hero:
		remove_child(hero)
		hero.queue_free()
	
	generate_exits()
	generate_entities(obstacles, 3) #rand_range(3, 4))
	generate_entities(treasures, 1, true)#rand_range(1, 2))

	move_child(hero, get_child_count())
	entities_by_coord.erase(entrance_coord)
	return hero


func generate_exits():
	var entrance_side = randi() % 4
	entrance_coord = get_coord_on_side(entrance_side)
	hero = spawn(hero_resource, entrance_coord)

	var exit_side = (entrance_side + 2) % 4
	var exit_coord = get_coord_on_side(exit_side)
	spawn(exit, exit_coord)


func generate_entities(resource_list, count, avoid_repeats = false):
	var bucket = []
	for n in range(count):
		if not bucket:
			bucket.append_array(resource_list)
		
		var i = randi() % bucket.size()
		var resource = bucket[i]
		if avoid_repeats:
			bucket.pop_at(i)
		
		while entities_by_coord.size() < floor_width * floor_height:
			var coord = Vector2(randi() % floor_width, randi() % floor_height)
			if not coord in entities_by_coord:
				spawn(resource, coord)
				break


func spawn(resource, coord):
	var entity = resource.instance()
	add_child(entity)
	entities_by_coord[coord] = entity
	entity.position = coord * tilesize
	return entity


func generate_tiles():
	tilemap.clear()
	for x in range(-1, floor_width + 1, 1):
		tilemap.set_cell(x, -1, 2)
		tilemap.set_cell(x, floor_height, 2)
	for y in range(floor_height):
		tilemap.set_cell(-1, y, 2)
		tilemap.set_cell(floor_width, y, 2)
	
	for x in range(floor_width):
		for y in range(floor_height):
			tilemap.set_cell(x, y, 1 if (x + y) % 2 else 3)


func is_in_bounds(coord):
	return coord.x >= 0 and coord.x < floor_width \
		and coord.y >= 0 and coord.y < floor_height


func get_coord_on_side(side):
	if side % 2:
		return Vector2(0 if side < 2 else floor_width - 1, randi() % floor_height)
	else:
		return Vector2(randi() % floor_width, 0 if side < 2 else floor_height - 1)
	

func rand_range(low, high):
	return randi() % (high - low) + low
