extends Node2D


var paused_update: bool

onready var bg = $Background
onready var tree = get_tree()


func _ready():
	visible = false


func _process(delta):
	if tree.paused:
		if not paused_update:
			visible = true
			paused_update = true
	elif paused_update:
		visible = false
		paused_update = false
