extends Control

var dialog
var line = 0
var JsonData
var timer
var dialogwait = 2
var isTimerTimeout = 1
var UpDialogBoxAppeared = false
var DownDialogBoxAppeared = false

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
				showUpBox()
			if UpDialogBoxAppeared == true:
				$UpBox/UpDialogBox/UpPortraitMargin/UpPortraitTexture.texture = load(
				"res://GUI/Portraits/" + JsonData[line].name + JsonData[line].emotion + ".png")
				up_text()
		elif JsonData[line].position == 1:
			if JsonData[line].command == 1:
				showDownBox()
			if DownDialogBoxAppeared == true:
				$DownBox/DownDialogBox/DownPortraitMargin/DownPortraitTexture.texture = load(
				"res://GUI/Portraits/" + JsonData[line].name + JsonData[line].emotion + ".png")
				down_text()
	else:
		$UpBox/UpAnimation.play("Disappear")
		$DownBox/DownAnimation.play("Disappear")
		yield($UpBox/UpAnimation,"animation_finished")
		yield($DownBox/DownAnimation,"animation_finished")
		queue_free()
	line += 1

func up_text():
	$UpBox/UpDialogBox/UpTextMargin/UpText.bbcode_text = JsonData[line].text
	$UpBox/UpDialogBox/NinePatchRect/UpNameMargin/UpName.bbcode_text = "[center]"+JsonData[line].name
	$UpBox/UpDialogBox/UpTextMargin/UpText.percent_visible = 0
	$UpBox/UpDialogBox/Tween.interpolate_property($UpBox/UpDialogBox/UpTextMargin/UpText, "percent_visible", 0,1,0.4, Tween.TRANS_SINE,Tween.EASE_IN)
	$UpBox/UpDialogBox/Tween.start()

func down_text(): 
	$DownBox/DownDialogBox/DownTextMargin/DownText.bbcode_text = "[right]"+JsonData[line].text
	$DownBox/DownDialogBox/NinePatchRect2/DownNameMargin/DownName.bbcode_text = "[center]"+JsonData[line].name
	$DownBox/DownDialogBox/DownTextMargin/DownText.percent_visible = 0
	$DownBox/DownDialogBox/Tween.interpolate_property($DownBox/DownDialogBox/DownTextMargin/DownText, "percent_visible", 0,1,0.4, Tween.TRANS_SINE,Tween.EASE_IN)
	$DownBox/DownDialogBox/Tween.start()

func showUpBox():
	get_node("UpBox").show()
	$UpBox/UpAnimation.play("Appear")
	UpDialogBoxAppeared = true

func showDownBox():
	get_node("DownBox").show()
	$DownBox/DownAnimation.play("Appear")
	DownDialogBoxAppeared = true
