extends AudioStreamPlayer


onready var thing_to_play_on_top = $LoopThingy


func _ready():
	connect("finished", self, "properly_loop")
	play()


func properly_loop():
	thing_to_play_on_top.play()
