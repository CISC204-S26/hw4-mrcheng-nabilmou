class_name Interactable extends Area2D

# Would need to code for switches, buttons, NPC dialogue triggers.
@export var interact_note_text: String = "" # for notes or dialogue
@export var interaction_type: String = "Basic" # can only be note, door, npc, or drive

@onready var envelope = $LetterSprite
@onready var note_ui = $NoteUI
@onready var note_label = $NoteUI/NoteLabel
@onready var tilemap = $NoteUI/NoteTileMapLayer


func interact():
	match interaction_type:
		"note":
			print("Interacted with NOTE")
			show_note()
		"door":
			pass
		"npc":
			pass
		"drive":
			pass


# ---- CODE FOR NOTES # CODE FOR NOTES # CODE FOR NOTES # CODE FOR NOTES ----- #
func show_note():
	if note_ui.visible:
		note_ui.visible = false
		get_tree().paused = false # unpause player while note closed
	else:
		note_ui.visible = true
		get_tree().paused = true # pause player while note open



func _on_note_area_2d_body_entered(body: Node):
	if body.name == "Player":
		envelope.play("Open")


func _on_note_area_2d_body_exited(body: Node):
	if body.name == "Player":
		envelope.play("Closed")
