extends AnimatedSprite

export var jsonname = ""
signal StartDialog(jsonname)


func _ready():
	playing = true


func _process(delta):
	if Input.is_action_just_pressed("Interact") and Global.inZone == true and Global.DialogStarted == false:
		Global.emit_signal("StartDialog",jsonname)
	if Input.is_action_just_pressed("Debug4"):
		print("This will cause issues if the dialog was already open.")
		print("In the future, force resetting a dialog will force close it via ResetBoxes().")
		# this is a condition check btw, not an assign operation
		Global.DialogStarted == false
		
func _on_Area2D_body_entered(body: Node2D):
	Global.DialogPosition = $Position2D.global_position
	Global.inZone = true

func _on_Area2D_body_exited(area):
	Global.inZone = false

