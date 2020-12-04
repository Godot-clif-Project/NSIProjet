extends Node

signal StartDialog(jsonname)
signal DialogStarted(playerInfo)
signal DialogFinished()
signal CutscenePlayerStoppedMoving(
	did_they_manage_to_reach_the_specified_position_though_im_really_curious_this_is_a_bool
)
var DialogStarted = false
var DialogPosition = Vector2(0,0)
func _init():
	OS.window_size = Vector2(854, 480)
	OS.center_window()


func _ready():
	pass	


class CutscenePlayerInfo:
	"""
	If set_position is true, the player will try to move to a position on the
	  x-axis when the cutscene starts.
	Setting movement_speed to -1 uses the default movement speed, set in
	  'Player.gd'.
	Set facing to -1 for the player to face left, or 1 for them to face right
	  after moving.
	maximum_time defines the duration the player will keep trying to move
	  towards the location before giving up.
	"""
	var set_position: bool
	var position_x: float
	var facing: int
	var movement_speed: float
	var maximum_time: float
	func _init(p_set_position: bool = false, p_position_x: float = 0, p_facing: int = 0,
			   p_movement_speed: float = -1, p_maximum_time: float = 5.0):
		set_position = p_set_position
		position_x = p_position_x
		facing = p_facing
		movement_speed = p_movement_speed
		maximum_time = p_maximum_time
