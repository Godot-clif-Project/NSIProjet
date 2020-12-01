extends Node

signal StartDialog(jsonname)
signal DownTalkAnimation()
signal UpTalkAnimation()
signal StopDownTalkAnimation()
signal StopUpTalkAnimation()

var WasInitialized = false
var isTalking = false
var UpTweenCompleted = false
var DownTweenCompleted = false

func _init():
	OS.window_size = Vector2(1280, 720)
	OS.center_window()


func _ready():
	pass
