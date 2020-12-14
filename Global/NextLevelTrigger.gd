extends Area2D


var player_velocity: Vector2

enum Direction {LEFT, RIGHT, UP, DOWN}
export(Direction) var transition_direction

enum NextOrPrevious {PREVIOUS = -1, NEXT = 1}
export(NextOrPrevious) var next_or_previous


func _ready():
	connect("body_entered", self, "next_level")
	visible = false


func next_level(body):
	if body.name == "Player":
		if not Global.loading_level:
			if Global.update_level(next_or_previous):
				player_velocity = body.velocity
				Global.loading_level = true
				Global.connect("transition_animation_finished", self, "leaving")
				if transition_direction == Direction.LEFT:
					Global.transition.sprite.rotation = PI
					Global.transition.play_backwards("OpenX")
					Global.emit_signal(
						"DialogStarted",
						Global.CutscenePlayerInfo.new(true, 9999999)
					)
				if transition_direction == Direction.RIGHT:
					Global.transition.sprite.rotation = 0
					Global.transition.play_backwards("OpenX")
					Global.emit_signal(
						"DialogStarted",
						Global.CutscenePlayerInfo.new(true, -9999999)
					)


func leaving():
	Global.disconnect("leaving_animation_finished", self, "leaving")
	Global.load_level(int(next_or_previous + 1 / 2), player_velocity)
