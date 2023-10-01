extends Node2D

export var heart_width = 7
export(Color) var heart_color
var heart_res = preload("res://ui/HealthBarHeart.tscn")

func set(current_health, max_health):
	var i = 0
	while i < max_health:
		var heart = get_child(i)
		if not heart:
			heart = heart_res.instance()
			add_child(heart)
			heart.position.x = i * heart_width
			heart.modulate = heart_color
		heart.visible = true
		heart.play("full" if i < current_health else "empty")
		i += 1
	
	while i < get_child_count():
		get_child(i).visible = false
		i += 1
