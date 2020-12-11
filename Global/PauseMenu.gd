extends Node2D


var paused_update: bool

onready var bg = $Background
onready var tree = get_tree()

onready var optionsmenu = get_node("Options")
onready var mainpause = get_node("Main")


func _ready():
	visible = false
	mainpause.hide()
	optionsmenu.hide()


func _process(delta):
	if tree.paused:
		if not paused_update:
			visible = true
			paused_update = true
			mainpause.show()
	elif paused_update:
		visible = false
		paused_update = false

# Main Menu Buttons

func _on_Resume_gui_input(event):
	if Input.is_action_just_pressed("menu_confirm"):
		tree.paused = false


func _on_Options_gui_input(event):
	if Input.is_action_just_pressed("menu_confirm"):
		mainpause.hide()
		optionsmenu.show()


func _on_Quit_gui_input(event):
	if Input.is_action_just_pressed("menu_confirm"):
		tree.quit()

# Options Menu Buttons

func _on_Return_gui_input(event):
	if Input.is_action_just_pressed("menu_confirm"):
		optionsmenu.hide()
		mainpause.show()
