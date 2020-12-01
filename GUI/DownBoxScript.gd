extends Control

var TweenComplete = true
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Tween_tween_completed(object, key):
	Global.DownTweenCompleted = 1
	Global.emit_signal("StopDownTalkAnimation")

func _on_Tween_tween_started(object, key):
	Global.DownTweenCompleted = 0
	Global.emit_signal("DownTalkAnimation")
