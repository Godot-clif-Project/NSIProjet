extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Tween_tween_completed(object, key):
	Global.UpTweenCompleted = 1
	Global.emit_signal("StopUpTalkAnimation")
#	print(UpTweenComplete)
	 # Replace with function body.


func _on_Tween_tween_started(object, key):
	Global.UpTweenCompleted = 0
	Global.emit_signal("UpTalkAnimation")
#	print(UpTweenComplete)
