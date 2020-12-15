extends Node

signal StartDialog(jsonname)
signal DialogStarted(playerInfo)
signal DialogFinished()
signal CutscenePlayerStoppedMoving(
	did_they_manage_to_reach_the_specified_position_though_im_really_curious_this_is_a_bool
)
signal MoveCharacter(charaname,xaxis)
#vraiment useless, reset position; mais...Je laisse là au cas où !
signal ResetPosition(charaname)

var DialogStarted = false
var DialogPosition = Vector2(0,0)
var inZone = false

var settings

var gameRunning = true
var ticks: int

var where_particles_should_be: Node
var camera: Node

var rng: RandomNumberGenerator

var fullscreen: bool
var window_normal_size = Vector2(854, 480)

var level_list = []
var current_level_id = 0
var current_level: String
var loading_level = false
var transition: Node
signal transition_animation_finished()
# 0 = starting point
# 1 = end point
signal entering_level(spawnpoint, player_velocity)

onready var tree = get_tree()


func _init():
	OS.window_size = window_normal_size


func _ready():
	rng = RandomNumberGenerator.new()
	rng.randomize()
	OS.window_borderless = false
	OS.center_window()
	level_list = [
		"res://Levels/Tutorial/1.tscn",
		"res://Levels/Tutorial/2.tscn",
		"res://Levels/Tutorial/3.tscn",
		"res://Levels/Tutorial/4.tscn",
		"res://Levels/Tutorial/5.tscn"
	]
	current_level_id = 0
	current_level = level_list[current_level_id]


func _process(delta):
	if Input.is_action_just_pressed("fucking_restart"):
		tree.reload_current_scene()
	if Input.is_action_just_pressed("Fullscreen"):
		if fullscreen:
			OS.window_maximized = false
			OS.window_size = window_normal_size
			OS.center_window()
			OS.window_borderless = false
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			fullscreen = false
		else:
#			OS.window_size = OS.get_screen_size()
#			OS.window_position = Vector2(0, 0)
			OS.window_borderless = true
			OS.window_maximized = true
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
			fullscreen = true
	if Input.is_action_just_pressed("Pause"):
		tree.paused = !tree.paused


func _physics_process(delta):
	if gameRunning:
		ticks += 1


func update_level(id_offset: int = 0) -> bool:
	if (
		current_level_id + id_offset >= 0 and
		current_level_id + id_offset < len(level_list)
	):
		current_level_id += id_offset
		return true
	else:
		print("Tried to put current_level_id out of range! From ", 
			  current_level_id, " to ", current_level_id + id_offset)
		return false


func load_level(spawnpoint: int = 0, player_velocity: Vector2 = Vector2.ZERO):
	current_level = level_list[current_level_id]
	tree.change_scene(current_level)
	emit_signal("entering_level", spawnpoint, player_velocity)
	Global.loading_level = false


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
