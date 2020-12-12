extends Node2D


var paused_update: bool

onready var bg = $Background
onready var tree = get_tree()

onready var optionsmenu = get_node("Options Menu")
onready var mainpause = get_node("Main")
onready var musicoptionsmenu = get_node("Music Options Menu")
onready var inputoptionsmenu = get_node("Input Options Menu")

var MusicVolume
var GUISFXVolume
var WorldSFXVolume

func _ready():
	visible = false
	mainpause.hide()
	optionsmenu.hide()
	musicoptionsmenu.hide()
	inputoptionsmenu.hide()
	Global.settings = self


func _process(delta):
	if tree.paused:
		if not paused_update:
			visible = true
			paused_update = true
			optionsmenu.hide()
			mainpause.show()
	elif paused_update:
		visible = false
		paused_update = false
		optionsmenu.hide()
		musicoptionsmenu.hide()
		inputoptionsmenu.hide()

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

#Music Options

func _on_MusicSlider_value_changed(value):
	MusicVolume = value

func _on_WorldSFXSlider_value_changed(value):
	WorldSFXVolume = value

func _on_GUISFXSlider_value_changed(value):
	GUISFXVolume = value

func _on_MusicReturn_gui_input(event):
	if Input.is_action_just_pressed("menu_confirm"):
		musicoptionsmenu.hide()
		optionsmenu.show()

#Input Options

func _on_InputReturn_gui_input(event):
	if Input.is_action_just_pressed("menu_confirm"):
		inputoptionsmenu.hide()
		optionsmenu.show()

func _on_Music_Options_gui_input(event):
	if Input.is_action_just_pressed("menu_confirm"):
		optionsmenu.hide()
		musicoptionsmenu.show()

func _on_Input_Options_gui_input(event):
	if Input.is_action_just_pressed("menu_confirm"):
		optionsmenu.hide()
		inputoptionsmenu.show()
