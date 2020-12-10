extends AudioStreamPlayer


onready var thing_to_play_on_top = $LoopThingy

var previous_position: float


func _ready():
	play()

func _process(delta):
	if get_playback_position() < previous_position:
		thing_to_play_on_top.play()
	previous_position = get_playback_position()
