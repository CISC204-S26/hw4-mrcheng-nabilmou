extends Node2D
@export var level_to_load: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_static_body_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player" and level_to_load:
		get_tree().change_scene_to_packed(level_to_load)
