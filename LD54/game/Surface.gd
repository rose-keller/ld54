extends Node2D

var tilesize = 8
var height = 8
var width = 12

func reset():
	for entity in $Entities.get_children():
		entity.queue_free()
	visible = false
	
func restart(hero_names):
	reset()
	visible = true
	
	var x = floor((width - 1) / 2)
	var y = 3
	for hero in hero_names:
		spawn(hero, Vector2(x, y))
		x += 1
		y -= 1
	
	for item in $Shop.get_children():
		item.reset()


func is_in_bounds(coord):
	return coord.x >= 0 and coord.x < width \
		and coord.y >= 0 and coord.y < height

func spawn(name, coord):
	var path = name if name.begins_with("res:") else "res://entities/%s.tscn" % name
	var resource = load(path)
	var entity = resource.instance()
	$Entities.add_child(entity)
	entity.add_to_group("entities")
	entity.add_to_group("heroes")
	entity.position = coord * tilesize
	return entity
