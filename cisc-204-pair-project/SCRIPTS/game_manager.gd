extends Node

var drives_collected = 0
var lab_complete: bool = false
var office_complete: bool = false

func can_enter_final_room():
	return lab_complete and office_complete and drives_collected >= 5
