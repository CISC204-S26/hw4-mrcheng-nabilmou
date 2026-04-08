extends Node

# tracks if player finished all puzzles and collected all drives
var drives_collected = 0
var lab_complete: bool = false
var office_complete: bool = false

# once player does everything they may enter final room
func can_enter_final_room():
	return lab_complete and office_complete and drives_collected >= 5
