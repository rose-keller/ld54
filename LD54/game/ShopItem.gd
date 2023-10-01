extends Interactable

export(Array, int) var price_array = [10]
export var infinite_purchase = false
var use_count = 0

func _ready():
	reset()


func reset():
	if use_count < price_array.size() or infinite_purchase:
		self.visible = true
		dead = false
		set_price(price_array[0 if infinite_purchase else use_count])


func set_price(price):
	$Label.text = "%d" % price
	
	for child in get_children():
		if "consume_amount" in child:
			child.consume_amount = price
