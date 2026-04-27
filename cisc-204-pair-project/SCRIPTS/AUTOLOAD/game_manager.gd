extends Node


# tracks if player finished all puzzles and collected all drives
var drives_collected = 0
var has_keycard1: bool = false
var has_keycard2: bool = false
var num_keys: int = 0 
var num_harddrive: int = 0
var door_unlocked: bool = false

var collected_ids: Array = []
var pickup_item: AudioStreamPlayer
var bg_music: AudioStreamPlayer
var bg_music2: AudioStreamPlayer


func _ready():
	var root = get_tree().get_root()
	if get_parent() != root:
		get_parent().remove_child(self)
		root.add_child(self)
	
	pickup_item = AudioStreamPlayer.new()
	add_child(pickup_item)
	pickup_item.stream = load("res://ASSETS/AUDIO/INTERACTABLE/pickup_item.wav")
	pickup_item.volume_db = -4
	pickup_item.max_polyphony = 3
	
	bg_music = AudioStreamPlayer.new()
	add_child(bg_music)
	bg_music.stream = load("res://ASSETS/AUDIO/BACKGROUND/dark_ambient_drone.wav")
	bg_music.volume_db = -16
	
	bg_music2 = AudioStreamPlayer.new()
	add_child(bg_music2)
	bg_music2.stream = load("res://ASSETS/AUDIO/BACKGROUND/empty_room_ambient.wav")
	bg_music2.volume_db = -10


func start_game_bg_music():
	if bg_music and not bg_music.playing:
		bg_music.play()
		
	if bg_music2 and not bg_music2.playing:
		bg_music2.play()

func stop_game_bg_music():
	if bg_music and bg_music.playing:
		bg_music.stop()
		
	if bg_music2 and bg_music2.playing:
		bg_music.stop()


# Final room requirement
func can_enter_final_room():
	if num_harddrive >= 5:
		print("You can enter the final room")
		return drives_collected >= 5


func give_keycard(level: int):
	if level == 1:
		has_keycard1 = true
	elif level == 2:
		has_keycard2 = true


func play_pickup_sound():
	if pickup_item:
			pickup_item.play()
