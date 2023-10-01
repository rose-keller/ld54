extends Node2D

export var heart_width = 7
export(Color) var heart_color
var heart_res = preload("res://ui/HealthBarHeart.tscn")

func set(current_health, max_health):
	var i = 0
	while i < round(max_health / 2.0):
		var heart = get_child(i)
		if not heart:
			heart = heart_res.instance()
			add_child(heart)
			heart.position.x = i * heart_width
			heart.modulate = heart_color
		heart.visible = true
		if i*2 >= current_health:
			heart.play("empty")
		elif i*2+1 == current_health:
			heart.play("half")
		else:
			heart.play("full")
		i += 1
	
	while i < get_child_count():
		get_child(i).visible = false
		i += 1
