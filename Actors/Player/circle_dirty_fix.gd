extends Sprite


func _process(delta):
	var difference: Vector2 = global_position - global_position.round()
	offset = difference
