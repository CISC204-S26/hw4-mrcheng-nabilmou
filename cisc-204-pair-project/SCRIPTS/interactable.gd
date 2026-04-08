class_name Interactable extends Area2D

# Would need to code for switches, buttons, NPC dialogue triggers.
@export var interact_note_text: String = "" # for notes or dialogue
@export var interaction_type: String = "Basic" # can only be note, door, npc, or drive

@onready var envelope = $LetterSprite
@onready var note_ui = $NoteUI
@onready var note_label = $NoteUI/NoteTexture/NoteLabel
@onready var note_texture = $NoteUI/NoteTexture


func _ready():
	note_ui.visible = false


func interact():
	match interaction_type:
		"note":
			print("Interacted with NOTE")
			toggle_note()
		"door":
			pass
		"npc":
			pass
		"drive":
			pass


# ---- CODE FOR NOTES # CODE FOR NOTES # CODE FOR NOTES # CODE FOR NOTES ----- #
func toggle_note():
	var player = get_tree().get_first_node_in_group("player")
	
	if note_ui.visible:
		note_ui.visible = false
		if player:
			player.can_move = true
	else:
		note_label.text = interact_note_text
		note_ui.visible = true
		if player:
			player.can_move = false

func _on_note_area_2d_body_entered(body: Node):
	if body.name == "Player":
		envelope.play("Open")

func _on_note_area_2d_body_exited(body: Node):
	if body.name == "Player":
		envelope.play("Closed")
