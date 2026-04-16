extends Node2D


@export var level_to_load: PackedScene


func _on_static_body_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player" and level_to_load:
		get_tree().change_scene_to_packed(level_to_load)
