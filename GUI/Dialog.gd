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
	get_node("UpBox").hide()
	get_node("DownBox").hide()

func _process(delta):
	if Input.is_action_just_pressed("Debug1"):
		proceed_dialog()

func proceed_dialog():
	if line < JsonData.size():
		if JsonData[line].position == 0:
			if JsonData[line].command == 1:
				get_node("UpBox").show()
			$UpBox/UpDialogBox/UpPortraitMargin/UpPortraitTexture.texture = load(
			"res://GUI/Portraits/" + JsonData[line].name + JsonData[line].emotion + ".png")
			up_text()
		elif JsonData[line].position == 1:
			if JsonData[line].command == 1:
				get_node("DownBox").show()
			$DownBox/DownDialogBox/DownPortraitMargin/DownPortraitTexture.texture = load(
			"res://GUI/Portraits/" + JsonData[line].name + JsonData[line].emotion + ".png")
			down_text()
			
	else:
		queue_free()
	line += 1

func up_text():
	$UpBox/UpDialogBox/UpTextMargin/UpText.bbcode_text = JsonData[line].text
	$UpBox/UpDialogBox/UpNameMargin/UpName.bbcode_text = JsonData[line].name
	$UpBox/UpDialogBox/UpTextMargin/UpText.percent_visible = 0
	$UpBox/UpDialogBox/Tween.interpolate_property($UpBox/UpDialogBox/UpTextMargin/UpText, "percent_visible", 0,1,0.4, Tween.TRANS_SINE,Tween.EASE_IN)
	$UpBox/UpDialogBox/Tween.start()

func down_text():
	$DownBox/DownDialogBox/DownTextMargin/DownText.bbcode_text = JsonData[line].text
	$DownBox/DownDialogBox/DownNameMargin/DownName.bbcode_text = "[right]"+JsonData[line].name
	$DownBox/DownDialogBox/DownTextMargin/DownText.percent_visible = 0
	$DownBox/DownDialogBox/Tween.interpolate_property($DownBox/DownDialogBox/DownTextMargin/DownText, "percent_visible", 0,1,0.4, Tween.TRANS_SINE,Tween.EASE_IN)
	$DownBox/DownDialogBox/Tween.start()
