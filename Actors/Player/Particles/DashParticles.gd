extends CPUParticles2D


var player_reference: Node


func _ready():
#	print("DashParticles added to tree")
	pass


func _process(delta):
	position = player_reference.position
