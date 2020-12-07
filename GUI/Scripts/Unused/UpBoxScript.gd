extends Control

func _on_Tween_tween_completed(object, key):
	Global.UpTweenCompleted = 1
	Global.emit_signal("StopUpTalkAnimation")


func _on_Tween_tween_started(object, key):
	Global.UpTweenCompleted = 0
	Global.emit_signal("UpTalkAnimation")
