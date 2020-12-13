extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var GoodPressesUntilEasterEgg = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(delta):
	if Input.is_key_pressed((KEY_C)):
		GoodPressesUntilEasterEgg += 1
	elif Input.is_key_pressed((KEY_O)) and GoodPressesUntilEasterEgg == 1:
		GoodPressesUntilEasterEgg += 1
	elif Input.is_key_pressed((KEY_M)) and GoodPressesUntilEasterEgg == 2:
		GoodPressesUntilEasterEgg += 1
	elif Input.is_key_pressed((KEY_M)) and GoodPressesUntilEasterEgg == 3:
		GoodPressesUntilEasterEgg += 1
	elif Input.is_key_pressed((KEY_I)) and GoodPressesUntilEasterEgg == 4:
		GoodPressesUntilEasterEgg += 1
	elif Input.is_key_pressed((KEY_T)) and GoodPressesUntilEasterEgg == 5:
		GoodPressesUntilEasterEgg += 1
	elif Input.is_key_pressed((KEY_PERIOD)) and GoodPressesUntilEasterEgg == 6:
		GoodPressesUntilEasterEgg += 1
	elif Input.is_key_pressed((KEY_M)) and GoodPressesUntilEasterEgg == 7:
		GoodPressesUntilEasterEgg += 1
	elif Input.is_key_pressed((KEY_P)) and GoodPressesUntilEasterEgg == 8:
		GoodPressesUntilEasterEgg += 1
	elif Input.is_key_pressed((KEY_4)) and GoodPressesUntilEasterEgg == 9:
		GoodPressesUntilEasterEgg = 0
		OS.shell_open("https://youtu.be/qfS6ZevQhd0")
	print(GoodPressesUntilEasterEgg)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
