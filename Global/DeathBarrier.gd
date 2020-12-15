extends Area2D


func _ready():
	connect("body_entered", self, "kill_player")


func kill_player(body):
	if body.name == "Player":
		body.die()
