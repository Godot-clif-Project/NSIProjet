extends RichTextLabel

var dialogfile = {}
var line = 0
var textfile = File.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	set_use_bbcode(true)
	textfile.open("res://GUI/text.json", File.READ)
	var parsedtextfile = textfile.get_as_text()
	var dialogfile = JSON.parse(parsedtextfile).result
	set_bbcode(dialogfile[line].text)
	textfile.close()
	print(dialogfile[1].text)

func _input(event):
	if Input.is_action_pressed("ui_accept"):
		line += 1
		set_bbcode(dialogfile[line].text)
