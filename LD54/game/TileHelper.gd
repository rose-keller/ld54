extends Node

var dirs = {"up": Vector2(0,-1), "left": Vector2(-1,0), "down": Vector2(0,1), "right": Vector2(1,0)}
var tile_size = 16
var sprite_offset = Vector2(tile_size / 2.0, tile_size)

func pos_to_coord(pos):
	return (pos - sprite_offset) / tile_size
	
func coord_to_pos(coord):
	return (coord * tile_size) + sprite_offset

func set_coord(node, coord):
	node.global_position = coord_to_pos(coord)

func get_coord(node):
	return get_fractional_coord(node).round()

func get_fractional_coord(node):
	return pos_to_coord(node.global_position)

func is_character_near(character, target, max_dist = 1):
	# in the future we could compare to a larger target area
	return are_coords_near(get_coord(character), get_coord(target));

func is_near_and_facing(character, target):
	if not "facing" in character:
		return false
	var char_coord = get_coord(character)
	char_coord += dirs[character.facing]
	# this only works from a single tile away, otherwise you might be close but facing away
	return are_coords_near(char_coord, get_coord(target), 0)

func are_coords_near(coord1, coord2, max_dist = 1):
	var diff = coord1 - coord2
	var dist = abs(diff.x) + abs(diff.y) # manhattan dist
	return dist < max_dist or is_equal_approx(dist, max_dist)

func get_dir_to_face(character, target):
	var diff = get_coord(target) - get_coord(character)
	if abs(diff.x) > abs(diff.y):
		return "right" if diff.x > 0 else "left"
	else:
		return "down" if diff.y > 0 else "up"

func is_tile_walkable(tilemap, coord):
	var cell = tilemap.get_cellv(coord)
	var shape_count = tilemap.tile_set.tile_get_shape_count(cell)
	return shape_count == 0
