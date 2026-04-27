extends CanvasLayer

signal dialogue_finished
@export var text_speed := 0.03

@onready var label := $DialogueBox/DialogueText
@onready var typing_sound := $"../TypingSound"

var lines: Array[String] = []
var current_line := 0
var full_text := ""
var typing := false


func show_text(new_lines: Array[String]):
	visible = true
	lines = new_lines
	current_line = 0
	
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.can_move = false
	
	_show_current_line()


func _show_current_line():
	full_text = lines[current_line]
	label.text = ""
	typing = true
	_type_text()


func _type_text():
	for i in full_text.length():
		if not typing:
			break
		
		label.text += full_text[i]
		
		if full_text[i] != " ":
			typing_sound.pitch_scale = randf_range(0.8, 1.1) # tone variation
			typing_sound.play()
		
		await get_tree().create_timer(text_speed).timeout
	
	label.text = full_text
	typing = false


func skip_or_close():
	# If still typing, finish instantly
	if typing:
		typing = false
		label.text = full_text
		return
		# Finished typing → go to next line
	current_line += 1
		# If more lines exist, show next
	if current_line < lines.size():
		_show_current_line()
		return
		# No more lines → close UI
	visible = false
	
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.can_move = true
	print("EMITTING dialogue_finished") 
	dialogue_finished.emit()
