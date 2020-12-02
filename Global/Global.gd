extends Node

signal StartDialog(jsonname)
signal DialogStarted()
signal DialogFinished()
var WasInitialized = false

func _init():
	OS.window_size = Vector2(1280, 720)
	OS.center_window()


func _ready():
	pass
