extends AnimationPlayer


var flipflop: bool = false

onready var sprite = $Sprite


func _ready():
	Global.transition = self
	sprite.visible = false
	# TEMP
	Global.connect("entering_level", self, "into_level")
	print("a")


# TEMP
func into_level(spawnpoint, player_velocity):
	Global.connect("transition_animation_finished", self, "temporary_code_lmao_this_name_is_bad")
	if spawnpoint == 1:
		sprite.rotation = PI
		play("OpenX")
	else:
		sprite.rotation = 0
		play("OpenX")

func temporary_code_lmao_this_name_is_bad():
	Global.disconnect("transition_animation_finished", self, "temporary_code_lmao_this_name_is_bad")
	sprite.visible = false


func anim_finished():
	if flipflop:
		Global.emit_signal("transition_animation_finished")
	flipflop = !flipflop
