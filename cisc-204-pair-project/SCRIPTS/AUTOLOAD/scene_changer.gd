extends Node


var fade_layer: CanvasLayer
var fade_rect: ColorRect
var is_transitioning := false
var target_spawn_marker: String = ""


func _ready():
	var root = get_tree().get_root()
	if get_parent() != root:
		get_parent().remove_child(self)
		root.add_child(self)


# ----------------------- CHANGING SCENES -----------------------------------------------
func change_scene(scene_path: String, spawn_marker: String):
	target_spawn_marker = spawn_marker
	
	await fade_out()
	
	get_tree().change_scene_to_file(scene_path)
	await get_tree().process_frame
	
	await fade_in()


# ----------------------- SCREEN FADE ---------------------------------------------------
func fade_out():
	ensure_fade()
	fade_rect.visible = true
	
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, 0.4)
	
	var player = get_tree().get_first_node_in_group("player")
	
	if player:
		player.can_move = false
	
	await tween.finished


func fade_in():
	ensure_fade()

	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 0.0, 0.4)
	
	await tween.finished
	
	fade_rect.visible = false
	
	var player = get_tree().get_first_node_in_group("player")
	
	if player:
		player.can_move = true


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
