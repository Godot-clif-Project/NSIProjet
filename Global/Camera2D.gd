extends Camera2D


const SHAKE_MAX = 4.0
const MOVEMENT_TEMP = Vector2(.12, .05)


class CameraPointOfInterest:
	var object: Node2D
	var intensity: float
	var max_distance: float
	var max_distance_sq: float
	var follow: bool
	func _init(p_obj: Node2D, p_intensity, p_max_dist, p_follow = false):
		object = p_obj
		intensity = p_intensity
		max_distance = p_max_dist
		max_distance_sq = max_distance * max_distance
		follow = p_follow


var raw_position: Vector2

var shake_force: float
var shake_timer: float
var shake_direction: Vector2

var points_of_interest = []
var movement: Vector2


func _init():
	Global.camera = self
	raw_position = position


func _physics_process(delta):
	if shake_timer > 0:
		offset = (
			shake_direction * Global.rng.randf() * shake_timer * shake_force * -1
		)
		shake_timer -= delta
	else:
		offset = Vector2.ZERO
	offset.clamped(SHAKE_MAX)
#	movement = Vector2.ZERO
#	var gpos = global_position
#	for poi in points_of_interest:
#		if poi.follow:
#			movement += (poi.object.global_position - gpos) * MOVEMENT_TEMP
#		else:
#			# Not implemented
#			pass


func shake(direction: Vector2, duration: float, force: float = 10.0):
	shake_direction = direction
	shake_timer = duration
	shake_force = force


func add_pt_of_interest(p_obj: Node2D, p_intensity: float,
						p_max_dist: float, p_follow = false):
	points_of_interest.push_back(
		CameraPointOfInterest.new(p_obj, p_intensity, p_max_dist, p_follow)
	)
