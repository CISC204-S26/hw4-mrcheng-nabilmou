extends Area2D

@export var target_scene_path: String
@export var target_spawn_marker: String 

# This variable is ONLY true when the player is allowed to use the hallway
var is_ready_to_trigger: bool = false

func _ready():
	# collision starts disabled
	is_ready_to_trigger = false
	await get_tree().create_timer(0.2).timeout
	# now tracks collisions
	is_ready_to_trigger = true

func _on_body_entered(body: Node):
	if is_ready_to_trigger and body.is_in_group("player"):
		is_ready_to_trigger = false
		SceneChanger.change_scene(target_scene_path, target_spawn_marker)
