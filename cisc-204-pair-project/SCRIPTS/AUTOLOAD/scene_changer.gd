extends Node


var fade_layer: CanvasLayer
var fade_rect: ColorRect
var player_ref: Node = null
var spawn_position: Vector2 = Vector2.ZERO
var is_transitioning := false


func register_player(player: Node):
	player_ref = player


func change_scene(path: String):
	if path == "":
		return
	
	await fade_out()
	get_tree().change_scene_to_file(path)
	await get_tree().process_frame
	apply_spawn()
	await fade_in()


func apply_spawn():
	print("APPLY SPAWN CALLED")
	
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	
	await get_tree().process_frame
	
	if spawn_position != Vector2.ZERO:
		player.global_position = spawn_position
	
	spawn_position = Vector2.ZERO


# ----------------------- SCREEN FADE ---------------------------------------------------
func fade_out():
	ensure_fade()
	fade_rect.visible = true
	
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, 0.4)
	
	if player_ref:
		player_ref.can_move = false
	
	await tween.finished


func fade_in():
	ensure_fade()

	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 0.0, 0.4)
	
	await tween.finished
	
	fade_rect.visible = false
	
	if player_ref:
		player_ref.can_move = true


# ------------------------ FADING SETUP --------------------------------------------------
func ensure_fade():
	if fade_layer:
		return
	
	# Creates a new scene without manually making one
	fade_layer = CanvasLayer.new()
	get_tree().root.add_child(fade_layer)

	# Sets the variables for canvaslayer
	fade_rect = ColorRect.new()
	fade_rect.color = Color(0, 0, 0)
	fade_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fade_rect.modulate.a = 0.0
	fade_rect.visible = false
	
	fade_layer.add_child(fade_rect)
