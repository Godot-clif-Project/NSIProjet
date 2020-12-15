extends AnimationPlayer


var flipflop: bool = false

onready var sprite = $Sprite
onready var worst_sprite = $i_hate_this_sprite

# TEMP
var spawnpoint: int


func _init():
	# TEMP
	Global.connect("entering_level", self, "into_level")

func into_level(p_spawnpoint, vel_idc):
	spawnpoint = p_spawnpoint


func _ready():
	Global.transition = self
	sprite.visible = true
	# TEMP
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


func TEMP_hide_the_pain():
	# because it can only be temporary :')
	worst_sprite.visible = false


func anim_finished():
	if flipflop:
		Global.emit_signal("transition_animation_finished")
	flipflop = !flipflop
