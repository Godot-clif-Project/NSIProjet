extends Control

# Command List in JSON:
# 0 : Simple Text
# 1 : Show Box
# 2 : Show Animation (in progress)
# 3 : Hide Box (to be added)

onready var TextBox = $DownDialogBox/DownTextMargin/DownText
onready var NameBox = $DownDialogBox/NinePatchRect2/DownNameMargin/DownName
onready var Portrait = $DownDialogBox/DownPortraitMargin/DownPortraitTexture
onready var AnimationMaster = $DownAnimation
onready var DownTween = $DownDialogBox/Tween
onready var BloopSound = $BloopSound
onready var timer = $Timer

var HowManyCharacters = 0
var DownTweenCompleted = true
var dialog
var line = 0
var JsonData
var DialogBoxAppeared = false
var IsTalking = false
var AnimationFinished = true
var OkFuckThisTroubleshootingTime = false
var DoesFileExist = false
var IsItHiddenByCode = false
var CharaPos

#If we ever need to show the old sprites in use; Change MC/Cool.tres to MC/CoolOld.tres
#Unknown didn't change through versions; so who cares about them (I do)
const MCFrames = preload("res://GUI/Portraits/MC.tres")
const CoolFrames = preload("res://GUI/Portraits/Cool.tres")
const UnknownFrames = preload("res://GUI/Portraits/Unknown.tres")

export var jsonname = "errorhandler"
export var lang = "FR"

func load_json(jsonname):
	var file = File.new();
	match lang:
		"FR":
			DoesFileExist = file.file_exists("res://GUI/Dialogues/FR/"+jsonname+".json")
			if DoesFileExist == true:
				file.open("res://GUI/Dialogues/FR/"+jsonname+".json", file.READ);
			else:
				file.open("res://GUI/Dialogues/EN/"+jsonname+".json", file.READ);
		"EN":
			DoesFileExist = file.file_exists("res://GUI/Dialogues/EN/"+jsonname+".json")
			if DoesFileExist == true:
				file.open("res://GUI/Dialogues/EN/"+jsonname+".json", file.READ);
			else:
				file.open("res://GUI/Dialogues/FR/"+jsonname+".json", file.READ);
		_:
			print("fix your language")
			file.open("res://GUI/Dialogues/FR/"+jsonname+".json", file.READ);
	JsonData = parse_json(file.get_as_text())
	file.close()

func _init():
	pass

func _ready():
	Global.connect("StartDialog",self,"StartDialogCode")
	Global.connect("CutscenePlayerStoppedMoving",self,"init_dialog")
	
	load_json(jsonname)
	hide()

func _process(delta):
	if jsonname != "":
		if AnimationFinished == true and DownTweenCompleted == true and Global.inZone == true:
			if not DialogBoxAppeared:
				if Input.is_action_just_pressed("Interact") and OkFuckThisTroubleshootingTime == false:
					start_dialog()
			elif DialogBoxAppeared:
				if Input.is_action_just_pressed("Accept") or Input.is_action_just_pressed("Interact"):
					proceed_dialog()
				if Input.is_action_just_pressed("Cancel"):
					# Code to make the dialog go faster or skip to the end of 
					# the text animation goes here
					pass
	else:
		print("Invalid JSON!!")
func start_dialog():
	Global.emit_signal("DialogStarted", Global.CutscenePlayerInfo.new(true, Global.DialogPosition.x, 1))

func init_dialog(shushubidu):
	if shushubidu == true:
		proceed_dialog()
		OkFuckThisTroubleshootingTime = true
	else:
		print("yo what the fuck")

func proceed_dialog():
	if line < JsonData.size():
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
#	DownTween.playback_speed = HowManyCharacters * TextSpeed
	if JsonData[line].text != "":
		TextBox.percent_visible = 0
		DownTween.interpolate_property(TextBox, "percent_visible", 0,1,0.4, Tween.TRANS_LINEAR,Tween.EASE_IN)
		DownTween.start()

func showDownBox():
	AnimationMaster.play("Appear")
	show()

func hideDownBox():
	AnimationMaster.play("Disappear")

func count_character_count():
	HowManyCharacters = 0
	for character in JsonData[line].text:
		HowManyCharacters += 1
	print(HowManyCharacters)
	down_text()
	line += 1

func DownBoxHandler(command):
	if command != 4: #Since it should be checked for every command...
		CheckIfCharacterShouldBeMoved()
	else: #Command 4 moves characters.
		MoveCharacter()
	if command == 1: # Show Box
		if DialogBoxAppeared == false:
			showDownBox()
		elif IsItHiddenByCode == true:
			show()
	elif command == 2: # Hide Box
		if DialogBoxAppeared == true:
			hide()
			IsItHiddenByCode = true
	if DialogBoxAppeared == true:
		if line < JsonData.size():
#			count_character_count()
			down_text()
			line += 1
func CheckIfCharacterShouldBeMoved():
	if JsonData[line].characterpos != "":
		print("characterpos is not empty! Forcing movement!")
		MoveCharacter()
func MoveCharacter():
	print("Here, the character should be...at ",JsonData[line].characterpos,".")
	CharaPos = get_node(JsonData[line].ID+JsonData[line].characterpos).global_position
	print(CharaPos.x)
func ResetBoxes():
	hide()
	Global.DialogStarted = false
	line = 0
	TextBox.percent_visible = 0
	DialogBoxAppeared = false
	OkFuckThisTroubleshootingTime = false

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
		Global.DialogStarted = true



func _on_Tween_tween_completed(object, key):
	DownTweenCompleted = true
	BloopSound.stop()
	StopDownTalkAnimation()

func _on_Tween_tween_started(object, key):
	DownTweenCompleted = false
	BloopSound.play()
	DownTalkAnimation()


func _on_DownAnimation_animation_finished(anim_name):
	match anim_name:
		"Appear":
			DialogBoxAppeared = true
			proceed_dialog()
		"Disappear":
			DialogBoxAppeared = false
		_:
			AnimationFinished = true


func _on_DownAnimation_animation_started(anim_name):
	match anim_name:
		"Appear":
			DialogBoxAppeared = false
		"Disappear":
			DialogBoxAppeared = true
		_:
			AnimationFinished = false
