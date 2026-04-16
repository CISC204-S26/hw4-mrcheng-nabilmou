extends Area2D


@export var target_scene_path: String

@onready var exit_left: Marker2D = $ExitLeft
@onready var exit_right: Marker2D = $ExitRight


func _on_body_entered(body: Node):
	if not body.is_in_group("player"):
		return
	
	# debug
	var pos = _get_spawn_position(body)
	print("HALL TRIGGER FIRED")
	print("CALCULATED SPAWN:", pos)
	
	SceneChanger.spawn_position = _get_spawn_position(body)
	SceneChanger.change_scene(target_scene_path)


func _get_spawn_position(player: Node) -> Vector2:
	# default fallback
	if exit_right == null or exit_left == null:
		return global_position
	
	# If player came from left side then spawn right side
	if player.global_position.x < global_position.x:
		return exit_right.global_position
	else:
		return exit_left.global_position
