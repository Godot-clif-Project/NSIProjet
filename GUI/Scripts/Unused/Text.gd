extends RichTextLabel

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
	load_json("convertcsv")

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		proceed_dialog()

func proceed_dialog():
	if line < JsonData.text.size:
		$RichText
