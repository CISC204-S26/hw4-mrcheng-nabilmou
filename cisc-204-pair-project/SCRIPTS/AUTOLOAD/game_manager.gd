extends Node

# tracks if player finished all puzzles and collected all drives
var drives_collected = 0
var has_keycard1: bool = false
var has_keycard2: bool = false
var num_keys: int = 0 
var num_harddrive: int = 0

# once player does everything they may enter final room
func can_enter_final_room():
	if num_harddrive >= 5:
		print("You can enter the final room")
		return drives_collected >= 5

func give_keycard(level: int):
	if level == 1:
		has_keycard1 = true
	elif level == 2:
		has_keycard2 = true
