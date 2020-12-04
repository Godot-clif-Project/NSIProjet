extends AnimatedSprite

export var jsonname = ""
var inZone = false
var WasInitialized = false
signal StartDialog(jsonname)


func _ready():
	playing = true


func _process(delta):
	if Input.is_action_just_pressed("Cancel") and inZone == true and Global.DialogStarted == false:
		Global.emit_signal("StartDialog",jsonname)
	if Input.is_action_just_pressed("Debug4"):
		print("This will cause issues if the dialog was already open.")
		print("In the future, force resetting a dialog will force close it via ResetBoxes().")
		Global.DialogStarted == false
		
func _on_Area2D_body_entered(body: Node2D):
	Global.DialogPosition = $Position2D.global_position
	jsonname = "CoolDialogue"
	inZone = true
	print(jsonname)

func _on_Area2D_body_exited(area):
	jsonname = "errorhandler"
	inZone = false

