extends Node2D # GOES ON ROOT NODE OF COMPLETE ROOM SCENE

@onready var player = $Player 

func _ready():
	# If the string is empty, player stays where you put them in editor
	if SceneChanger.target_spawn_marker == "":
		return
		
	# Find the marker anywhere in the scene
	var spawn_node = find_child(SceneChanger.target_spawn_marker, true, false)
	
	if spawn_node:
		player.global_position = spawn_node.global_position
		print("Teleported player to: ", SceneChanger.target_spawn_marker)
	
	# Clear it
	SceneChanger.target_spawn_marker = ""
