extends Camera2D


const SHAKE_MAX = 4.0


var raw_position: Vector2

var shake_force: float
var shake_timer: float
var shake_offset: Vector2
var shake_direction: Vector2


func _ready():
	Global.camera = self
	raw_position = position


func _process(delta):
	if shake_timer > 0:
		shake_offset = (
			shake_direction * Global.rng.randf() * shake_timer * shake_force * -2
		)
		shake_timer -= delta
	else:
		shake_offset = Vector2.ZERO
	shake_offset.clamped(SHAKE_MAX)
	position = raw_position + shake_offset


func shake(direction: Vector2, duration: float, force: float = 10.0):
	shake_direction = direction
	shake_timer = duration
	shake_force = force
