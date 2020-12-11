extends AudioStreamPlayer


const GUI_SFX_VOLUME = -20.0
const WORLD_SFX_VOLUME = -23.0
const MUSIC_VOLUME = -26.0

const MUSIC_ATTENUATION_WHEN_PAUSED = .3

var gui_sfx_id: int
var world_sfx_id: int
var music_id: int

var paused_update: bool

onready var tree = get_tree()

onready var thing_to_play_on_top = $LoopThingy


func _ready():
	connect("finished", self, "properly_loop")
	play()
	gui_sfx_id = AudioServer.get_bus_index("GUI SFX")
	world_sfx_id = AudioServer.get_bus_index("World SFX")
	music_id = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(gui_sfx_id, GUI_SFX_VOLUME)
	AudioServer.set_bus_volume_db(world_sfx_id, WORLD_SFX_VOLUME)
	AudioServer.set_bus_volume_db(music_id, MUSIC_VOLUME)


func _process(delta):
	if tree.paused:
		if not paused_update:
			AudioServer.set_bus_volume_db(
				music_id,
				MUSIC_VOLUME + ratio_to_decibel(MUSIC_ATTENUATION_WHEN_PAUSED)
			)
			paused_update = true
	elif paused_update:
		AudioServer.set_bus_volume_db(music_id, MUSIC_VOLUME)
		paused_update = false


func ratio_to_decibel(ratio: float) -> float:
	return 20 * (log(ratio) / log(10.0))


func properly_loop():
	thing_to_play_on_top.play()
