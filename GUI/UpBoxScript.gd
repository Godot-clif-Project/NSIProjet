extends Control

var UpTweenComplete = 1
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
	UpTweenComplete = 1
#	print(UpTweenComplete)
	 # Replace with function body.


func _on_Tween_tween_started(object, key):
	UpTweenComplete = 0
#	print(UpTweenComplete)
