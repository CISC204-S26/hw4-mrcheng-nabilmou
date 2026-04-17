extends Node


var fade_layer: CanvasLayer
var fade_rect: ColorRect
var player_ref: Node = null
var spawn_position: Vector2 = Vector2.ZERO
var is_transitioning := false


func _ready():
	var root = get_tree().get_root()
	if get_parent() != root:
		get_parent().remove_child(self)
		root.add_child(self)



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

'''
func apply_spawn():
	
	print("APPLY SPAWN CALLED")
	
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	
	await get_tree().process_frame
	
	if spawn_position != Vector2.ZERO:
		player.global_position = spawn_position
	
	spawn_position = Vector2.ZERO
'''


func apply_spawn():
	print("FOUND PLAYER:", get_tree().get_first_node_in_group("player"))
	print("APPLY SPAWN CALLED")
	# Wait until the player actually exists in the scene
	var player = get_tree().get_first_node_in_group("player")
	var attempts = 0
	while player == null and attempts < 10:
		await get_tree().process_frame
		player = get_tree().get_first_node_in_group("player")
		attempts += 1
	
	if player == null:
		print("ERROR: Player not found after scene load")
		return
	
	print("FOUND PLAYER:", player)
	print("SPAWN POSITION:", spawn_position)
		# Apply spawn
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
