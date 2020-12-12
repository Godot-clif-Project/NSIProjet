extends Node2D

signal MusicOptionsPressed()
signal InputOptionsPressed()
signal ReturnButtonPressed()

onready var ButtonContainer = get_node("VBoxContainer")
var ButtonList = []

var currentSelection = 0
var previousSelection = 0

func _ready():
	ButtonList = ButtonContainer.get_children()

func _process(delta):
	print(currentSelection)

func _input(event):
	previousSelection = currentSelection
	if Input.is_action_just_pressed("Down"):
		currentSelection += 1
	if Input.is_action_just_pressed("Up"):
		if currentSelection != 0:
			currentSelection -= 1
	if Input.is_action_just_pressed("menu_confirm"):
		send_signal(currentSelection)
	UpdateSelectionCheck()
func UpdateSelectionCheck():
	if currentSelection > (ButtonList.size() -1):
		currentSelection = 0
	UpdateSelection()

func UpdateSelection():
	ButtonList[previousSelection].set("custom_colors/font_color",Color(1,1,1))
	ButtonList[currentSelection].set("custom_colors/font_color", Color(1,0,0))

func _on_Main_visibility_changed():
	currentSelection = 0

func _on_Main_hide():
	currentSelection = 0
	set_process_input(false)
	for number in ButtonList.size():
		ButtonList[number].set("custom_colors/font_color",Color(1,1,1))

func send_signal(Selection):
	match Selection:
		0:
			emit_signal("MusicOptionsPressed")
		1:
			emit_signal("InputOptionsPressed")
		2:
			emit_signal("ReturnButtonPressed")

func _on_Main_draw():
	currentSelection = 0
	set_process_input(true)
	UpdateSelectionCheck()

