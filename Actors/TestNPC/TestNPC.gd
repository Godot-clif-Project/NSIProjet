extends Sprite

var inZone = false
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _process(delta):
	if Input.is_action_just_pressed("Debug1") and inZone == true:
		get_node("DialogueBox").load_json("test")
		get_node("DialogueBox").proceed_dialog()

func _on_Area2D_area_entered(body: Node2D):
	print("inthezone")
	get_node("DialogueBox").jsonname = "test"

func _on_Area2D_area_exited(area):
	print("outofthezone")
	get_node("DialogueBox").jsonname = "errorhandler"
