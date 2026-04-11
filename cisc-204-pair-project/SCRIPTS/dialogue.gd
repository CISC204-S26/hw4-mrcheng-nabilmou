extends Node2D

@export var text_speed := 0.03
var full_text := ""
var typing := false

@onready var label := $DialogueUI/DialogueBox/DialogueText

func show_text(text: String):
	visible = true
	full_text = text
	label.text = ""
	typing = true
	_type_text()

func _type_text():
	for i in full_text.length():
		if not typing:
			break
		label.text += full_text[i]
		await get_tree().create_timer(text_speed).timeout
	label.text = full_text
	typing = false

func skip_or_close():
	if typing:
		typing = false
		label.text = full_text
	else:
		visible = false
