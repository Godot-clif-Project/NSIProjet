extends Control

var dialog
var line = 0
var JsonData
var timer
var dialogwait = 2
var isTimerTimeout = 1
var UpDialogBoxAppeared = false
var DownDialogBoxAppeared = false
var UpIsTalking = false
var DownIsTalking = false
export var jsonname = "errorhandler"
onready var UpTextBox = $UpBox/UpDialogBox/UpTextMargin/UpText
onready var DownTextBox = $DownBox/DownDialogBox/DownTextMargin/DownText
onready var UpPortrait = $UpBox/UpDialogBox/UpPortraitMargin/UpPortraitTexture
onready var DownPortrait = $DownBox/DownDialogBox/DownPortraitMargin/DownPortraitTexture

func load_json(jsonname):
	var file = File.new();
	file.open("res://GUI/"+jsonname+".json", file.READ);
	JsonData = parse_json(file.get_as_text())
	file.close()

func _init():
	pass
func _ready():
	Global.connect("StartDialog",self,"StartDialogCode")
	
	Global.connect("UpTalkAnimation",self,"UpTalkAnimation")
	Global.connect("StopUpTalkAnimation",self,"StopUpTalkAnimation")
	
	Global.connect("DownTalkAnimation",self,"DownTalkAnimation")
	Global.connect("StopDownTalkAnimation",self,"StopDownTalkAnimation")
	
	load_json(str(jsonname))
	
	get_node("UpBox").hide()
	get_node("DownBox").hide()

func _process(delta):
	if jsonname != "" or "errorhandler":
		if Input.is_action_just_pressed("Debug1"):
			proceed_dialog()

func proceed_dialog():
	if line < JsonData.size():
		if JsonData[line].position == 0 :
			UpBoxHandler(JsonData[line].command)
		# Same code but for the Down Box. please help
		elif JsonData[line].position == 1:
			DownBoxHandler(JsonData[line].command)
	else:
		if UpDialogBoxAppeared == true:
			$UpBox/UpAnimation.play("Disappear")
			yield($UpBox/UpAnimation,"animation_finished")
		if DownDialogBoxAppeared == true:
			$DownBox/DownAnimation.play("Disappear")
			yield($DownBox/DownAnimation,"animation_finished")
		ResetBoxes()

func up_text():
	UpTextBox.bbcode_text = JsonData[line].text
	$UpBox/UpDialogBox/NinePatchRect/UpNameMargin/UpName.text = JsonData[line].name
	UpTextBox.percent_visible = 0
	$UpBox/UpDialogBox/Tween.interpolate_property(UpTextBox, "percent_visible", 0,1,0.4, Tween.TRANS_LINEAR,Tween.EASE_IN)
	$UpBox/UpDialogBox/Tween.start()

func down_text(): 
	DownTextBox.bbcode_text = "[right]"+JsonData[line].text
	$DownBox/DownDialogBox/NinePatchRect2/DownNameMargin/DownName.text = JsonData[line].name
	DownTextBox.percent_visible = 0
	$DownBox/DownDialogBox/Tween.interpolate_property(DownTextBox, "percent_visible", 0,1,0.4, Tween.TRANS_LINEAR,Tween.EASE_IN)
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
	if UpDialogBoxAppeared == true and DownIsTalking == false:
		#if $DownBox/DownDialogBox/DownTextMargin/DownText.percent_visible == 100:
		if line < JsonData.size():
			up_text()
			line += 1
	else:
		$UpBox/UpAnimation.play("Disappear")
		yield($UpBox/UpAnimation,"animation_finished")
#		$UpBox.queue_free()

func DownBoxHandler(command):
	if command == 1:
		if DownDialogBoxAppeared == false:
			showDownBox()
			yield($DownBox/DownAnimation,"animation_finished")
	if DownDialogBoxAppeared == true and UpIsTalking == false:
		#if $UpBox/UpDialogBox/UpTextMargin/UpText.percent_visible == 100:
		if line < JsonData.size():
			down_text()
			line += 1
	else:
		$DownBox/DownAnimation.play("Disappear")
		yield($DownBox/DownAnimation,"animation_finished")
#		$DownBox.queue_free()

func ResetBoxes():
	line = 0
	$DownBox/DownDialogBox/DownTextMargin/DownText.percent_visible = 0
	$UpBox/UpDialogBox/UpTextMargin/UpText.percent_visible = 0
	get_node("UpBox").hide()
	get_node("DownBox").hide()
	DownDialogBoxAppeared = false
	UpDialogBoxAppeared = false
	load_json("errorhandler")

func UpTalkAnimation():
	UpPortrait.animation = "talk"
	UpPortrait.play()
	UpIsTalking = true

func StopUpTalkAnimation():
	UpPortrait.animation = "default"
	UpPortrait.play()
	UpIsTalking = false

func DownTalkAnimation():
	DownPortrait.animation = "talk"
	DownPortrait.play()
	DownIsTalking = true

func StopDownTalkAnimation():
	DownPortrait.animation = "default"
	DownPortrait.play()
	DownIsTalking = false
	
func StartDialogCode(jsonname):
	if Global.WasInitialized == false:
		load_json(jsonname)
