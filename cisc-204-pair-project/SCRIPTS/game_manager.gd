extends Node

# tracks if player finished all puzzles and collected all drives
var drives_collected = 0
var has_keycard1: bool = false
var has_keycard2: bool = false
var num_keys: int = 0 #

# once player does everything they may enter final room
func can_enter_final_room():
	return drives_collected >= 5
