extends RichTextLabel

var dialog
var line = 0
var JsonData
var timer
var dialogwait = 2
var isTimerTimeout = 1

func load_json(jsonname):
	var file = File.new();
	file.open("res://GUI/"+jsonname+".json", file.READ);
	JsonData = parse_json(file.get_as_text())
	file.close()
	
func _ready():
	
	timer = get_node("./Timer")
	load_json("convertcsv")
	set_visible_characters(0)
	set_process_input(true)
	
func _input(event):
	if event is InputEventMouseButton or Input.is_action_pressed("ui_accept") :
		if get_visible_characters() > get_total_character_count():
			if line < JsonData.size()-1:
					line += 1
					set_bbcode("putain")
					set_bbcode(JsonData[line].text)
					$"/root/Control/Timer".start(dialogwait)
			else:
				set_bbcode("end of text?")
		else:
			set_visible_characters(get_total_character_count())

func _on_Timer_timeout():
	set_visible_characters(get_visible_characters()+1)

