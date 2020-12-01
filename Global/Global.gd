extends Node
signal StartDialog(jsonname)
var WasInitialized = false
func _init():
	OS.window_size = Vector2(1280, 720)
	OS.center_window()


func _ready():
	pass
