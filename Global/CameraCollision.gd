extends CollisionShape2D


var viewport_size: Vector2


func _ready():
	viewport_size = get_tree().get_root().size
	# TEMP
	shape.extents = Vector2(159.9, 86.9)
