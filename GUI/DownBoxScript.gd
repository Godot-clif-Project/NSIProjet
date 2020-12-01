extends Control

func _on_Tween_tween_completed(object, key):
	Global.DownTweenCompleted = 1
	Global.emit_signal("StopDownTalkAnimation")

func _on_Tween_tween_started(object, key):
	Global.DownTweenCompleted = 0
	Global.emit_signal("DownTalkAnimation")
