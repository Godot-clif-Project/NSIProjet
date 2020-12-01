extends Control

var dialog
var line = 0
var JsonData
var timer
var dialogwait = 2
var isTimerTimeout = 1
var UpDialogBoxAppeared = false
var DownDialogBoxAppeared = false
var jsonname = "errorhandler"

func load_json(jsonname):
	line = 0
	var file = File.new();
	file.open("res://GUI/"+jsonname+".json", file.READ);
	JsonData = parse_json(file.get_as_text())
	file.close()

func _init():
	pass
func _ready():
	load_json(str(jsonname))
	get_node("UpBox").hide()
	get_node("DownBox").hide()

func _process(delta):
	if Input.is_action_just_pressed("Debug1"):
		proceed_dialog()

func proceed_dialog():
	if line < JsonData.size():
		if JsonData[line].position == 0:
			UpBoxHandler(JsonData[line].command)
#			if JsonData[line].command == 1:
#				if UpDialogBoxAppeared == false:
#					showUpBox()
#					yield($UpBox/UpAnimation,"animation_finished")
#			if UpDialogBoxAppeared == true and $UpBox.TweenComplete == true:
#				if $DownBox/DownDialogBox/DownTextMargin/DownText.percent_visible == 0 or $DownBox/DownDialogBox/DownTextMargin/DownText.percent_visible == 100:
#					up_text()
#					line += 1
		# Same code but for the Down Box. please help
		elif JsonData[line].position == 1:
			DownBoxHandler(JsonData[line].command)
#			if JsonData[line].command == 1:
#				if DownDialogBoxAppeared == false:
#					showDownBox()
#					yield($DownBox/DownAnimation,"animation_finished")
#			if DownDialogBoxAppeared == true and $DownBox.TweenComplete == true:
#				if $UpBox/UpDialogBox/UpTextMargin/UpText.percent_visible == 0 or $UpBox/UpDialogBox/UpTextMargin/UpText.percent_visible == 100:
#					down_text()
#					line += 1
	else:
		$UpBox/UpAnimation.play("Disappear")
		yield($UpBox/UpAnimation,"animation_finished")
		$DownBox/DownAnimation.play("Disappear")
		yield($DownBox/DownAnimation,"animation_finished")
		ResetBoxes()

func up_text():
	$UpBox.TweenComplete == false
	$UpBox/UpDialogBox/UpPortraitMargin/UpPortraitTexture.texture = load(
	"res://GUI/Portraits/" + JsonData[line].name + JsonData[line].emotion + ".png")
	$UpBox/UpDialogBox/UpTextMargin/UpText.bbcode_text = JsonData[line].text
	$UpBox/UpDialogBox/NinePatchRect/UpNameMargin/UpName.bbcode_text = "[center]"+JsonData[line].name
	$UpBox/UpDialogBox/UpTextMargin/UpText.percent_visible = 0
	$UpBox/UpDialogBox/Tween.interpolate_property($UpBox/UpDialogBox/UpTextMargin/UpText, "percent_visible", 0,1,0.4, Tween.TRANS_SINE,Tween.EASE_IN)
	$UpBox/UpDialogBox/Tween.start()

func down_text(): 
	$DownBox.TweenComplete == false
	$DownBox/DownDialogBox/DownPortraitMargin/DownPortraitTexture.texture = load(
	"res://GUI/Portraits/" + JsonData[line].name + JsonData[line].emotion + ".png")
	$DownBox/DownDialogBox/DownTextMargin/DownText.bbcode_text = "[right]"+JsonData[line].text
	$DownBox/DownDialogBox/NinePatchRect2/DownNameMargin/DownName.bbcode_text = "[center]"+JsonData[line].name
	$DownBox/DownDialogBox/DownTextMargin/DownText.percent_visible = 0
	$DownBox/DownDialogBox/Tween.interpolate_property($DownBox/DownDialogBox/DownTextMargin/DownText, "percent_visible", 0,1,0.4, Tween.TRANS_SINE,Tween.EASE_IN)
	$DownBox/DownDialogBox/Tween.start()

func showUpBox():
	$UpBox/UpAnimation.play("Appear")
	get_node("UpBox").show()
	UpDialogBoxAppeared = true

func showDownBox():
	$DownBox/DownAnimation.play("Appear")
	get_node("DownBox").show()
	DownDialogBoxAppeared = true

func UpBoxHandler(command):
	if command == 1:
		if UpDialogBoxAppeared == false:
			showUpBox()
			yield($UpBox/UpAnimation,"animation_finished")
	if UpDialogBoxAppeared == true and $UpBox.TweenComplete == true:
		#if $DownBox/DownDialogBox/DownTextMargin/DownText.percent_visible == 100:
		up_text()
	else:
		$UpBox/UpAnimation.play("Disappear")
		yield($UpBox/UpAnimation,"animation_finished")
#		$UpBox.queue_free()
	line += 1

func DownBoxHandler(command):
	if command == 1:
		if DownDialogBoxAppeared == false:
			showDownBox()
			yield($DownBox/DownAnimation,"animation_finished")
	if DownDialogBoxAppeared == true and $DownBox.TweenComplete == true:
		#if $UpBox/UpDialogBox/UpTextMargin/UpText.percent_visible == 100:
		down_text()
	else:
		$DownBox/DownAnimation.play("Disappear")
		yield($DownBox/DownAnimation,"animation_finished")
#		$DownBox.queue_free()
	line += 1

func ResetBoxes():
	line = 0
	get_node("UpBox").hide()
	get_node("DownBox").hide()
	DownDialogBoxAppeared = false
	UpDialogBoxAppeared = false
	$DownBox/DownDialogBox/DownTextMargin/DownText.percent_visible = 0
	$UpBox/UpDialogBox/UpTextMargin/UpText.percent_visible = 0
	load_json("test")
