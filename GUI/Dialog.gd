extends Control

var dialog
var line = 0
var JsonData
var timer
var dialogwait = 2
var isTimerTimeout = 1

func load_json(jsonname):
	var file = File.new();
	file.open("res://GUI/"+jsonname+".json", file.READ);
	JsonData = parse_json(file.get_as_text())
	file.close()
	
func _ready():
	load_json("test")

func _process(delta):
	if Input.is_action_just_pressed("Accept"):
		proceed_dialog()

func proceed_dialog():
	if line < JsonData.size():
		$TextLabel.bbcode_text = JsonData[line].text
		$NameLabel.bbcode_text = JsonData[line].name
		$TextLabel.percent_visible = 0
		$Tween.interpolate_property($TextLabel, "percent_visible", 0,1,0.4, Tween.TRANS_SINE,Tween.EASE_IN)
		$Tween.start()
	else:
		queue_free()
	line += 1
