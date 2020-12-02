extends Control
onready var TextBox = $DownDialogBox/DownTextMargin/DownText
onready var NameBox = $DownDialogBox/NinePatchRect2/DownNameMargin/DownName
onready var Portrait = $DownDialogBox/DownPortraitMargin/DownPortraitTexture
onready var AnimationMaster = $DownAnimation
onready var DownTween = $DownDialogBox/Tween

var DownTweenCompleted = true
var dialog
var line = 0
var JsonData
var DialogBoxAppeared = false
var IsTalking = false
var PortraitPath = "res://GUI/Portraits/"
var AnimationFinished = true

const MCFrames = preload("res://GUI/Portraits/MC.tres")
const CoolFrames = preload("res://GUI/Portraits/Cool.tres")
const UnknownFrames = preload("res://GUI/Portraits/Unknown.tres")

export var jsonname = "errorhandler"

func load_json(jsonname):
	var file = File.new();
	file.open("res://GUI/Dialogues/"+jsonname+".json", file.READ);
	JsonData = parse_json(file.get_as_text())
	file.close()

func _init():
	pass
func _ready():
	Global.connect("StartDialog",self,"StartDialogCode")
	
	Global.connect("DownTalkAnimation",self,"DownTalkAnimation")
	Global.connect("StopDownTalkAnimation",self,"StopDownTalkAnimation")
	load_json("errorhandler")
	hide()

func _process(delta):
	if Input.is_action_just_pressed("Debug1") and AnimationFinished == true and DownTweenCompleted == true:
		proceed_dialog()

func proceed_dialog():
	if line < JsonData.size():
		if Global.DialogStarted == false:
			Global.DialogStarted = true
			Global.emit_signal("DialogStarted")
		ChangePortraitPosition()
		yield(AnimationMaster,"animation_finished")
		ChangePortrait()
		DownBoxHandler(JsonData[line].command)
	else:
		if DialogBoxAppeared == true:
			hideDownBox()
			Global.emit_signal("DialogFinished")
		yield(AnimationMaster,"animation_finished")
		ResetBoxes()
		
func down_text(): 
	TextBox.bbcode_text = "[center]"+JsonData[line].text
	NameBox.text = JsonData[line].name
	TextBox.percent_visible = 0
	DownTween.interpolate_property(TextBox, "percent_visible", 0,1,0.4, Tween.TRANS_LINEAR,Tween.EASE_IN)
	DownTween.start()

func showDownBox():
	AnimationMaster.play("Appear")
	show()
	DialogBoxAppeared = true

func hideDownBox():
	AnimationMaster.play("Disappear")
	DialogBoxAppeared = false

func DownBoxHandler(command):
	if command == 1:
		if DialogBoxAppeared == false:
			showDownBox()
	if DialogBoxAppeared == true:
		if line < JsonData.size():
			down_text()
			line += 1

func ResetBoxes():
	hide()
	Global.DialogStarted = false
	line = 0
	TextBox.percent_visible = 0
	hide()
	DialogBoxAppeared = false
	load_json("errorhandler")

func ChangePortraitPosition():
	if JsonData[line].position == 0:
		AnimationMaster.play("LeftPortrait")
	else:
		AnimationMaster.play("RightPortrait")

func ChangePortrait():
	match JsonData[line].name:
		"MC":
			Portrait.frames = MCFrames
		"Cool":
			Portrait.frames = CoolFrames
		_:
			Portrait.frames = UnknownFrames

func DownTalkAnimation():
	Portrait.animation = "talk"
	Portrait.play()
	IsTalking = true

func StopDownTalkAnimation():
	Portrait.animation = "default"
	Portrait.play()
	IsTalking = false
	
func StartDialogCode(jsonname):
	if Global.DialogStarted == false:
		load_json(jsonname)

func _on_Tween_tween_completed(object, key):
	DownTweenCompleted = true
	StopDownTalkAnimation()

func _on_Tween_tween_started(object, key):
	DownTweenCompleted = false
	DownTalkAnimation()


func _on_DownAnimation_animation_finished(anim_name):
	AnimationFinished = true


func _on_DownAnimation_animation_started(anim_name):
	AnimationFinished = false
