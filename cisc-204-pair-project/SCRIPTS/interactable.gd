class_name Interactable extends Area2D

# Would need to code for switches, buttons, NPC dialogue triggers.
@export var interaction_type: String = "Basic" # can only be note, door, npc, or harddrive
@export var note_text: String = "" # each note has its own text
@export var dialogue_text: String = "" # each NPC has its own dialogue line

# Checks if node with specific name exists, otherwise ignore it
@onready var envelope = $LetterSprite if has_node("LetterSprite") else null
@onready var note_ui = $NoteUI if has_node("NoteUI") else null
@onready var note_label = $NoteUI/NoteTexture/NoteLabel if has_node("NoteUI/NoteTexture/NoteLabel") else null
@onready var note_texture = $NoteUI/NoteTexture if has_node("NoteUI/NoteTexture") else null

@onready var dialogue_ui = $DialogueUI if has_node("DialogueUI") else null


func _ready():
	if note_ui:
		note_ui.visible = false


func interact():
	# This cleans the string so "Door" becomes "door"
	var clean_type = interaction_type.strip_edges().to_lower()
	print("INTERACT FUNCTION WAS CALLED ON: ", name)
	match clean_type:
		"note":
			print("Interacted with NOTE")
			toggle_note()
		"key":
			add_key()
		"door":
			try_open_door()
		"npc":
			start_dialogue()
		"harddrive":
			add_hard_drive()


func toggle_note():
	if note_ui == null:
		return  # Not a note-type interactable
	
	var player = get_tree().get_first_node_in_group("player")
	
	if note_ui.visible:
		note_ui.visible = false
		if player:
			player.can_move = true
	else:
		note_label.text = note_text
		note_ui.visible = true
		if player:
			player.can_move = false


func _on_note_area_2d_body_entered(body: Node):
	if body.name == "Player":
		envelope.play("Open")

func _on_note_area_2d_body_exited(body: Node):
	if body.name == "Player":
		envelope.play("Closed")

func add_key():
	print("Add Key function started!") 
	GameManager.num_keys += 1
	print("Picked up a key! Global keys:", GameManager.num_keys)
	queue_free()

func try_open_door():
	print("Attempting to open door...")
	
	# Check the Global Manager instead of the Player node
	if GameManager.num_keys > 0:
		GameManager.num_keys -= 1
		print("SUCCESS: Opening Door! Keys remaining: ", GameManager.num_keys)
		
		if has_node("StaticBody2D/CollisionShape2D"):
			$StaticBody2D/CollisionShape2D.set_deferred("disabled", true)
		
		if has_node("AnimatedSprite2D"):
			$AnimatedSprite2D.play("Door open") 
			await $AnimatedSprite2D.animation_finished
		
		#queue_free()
	else:
		print("LOCKED: You have 0 keys in GameManager.")


func start_dialogue():
	print("started dialogue")
	if dialogue_ui == null:
		return
	var player = get_tree().get_first_node_in_group("player")
	
	# If bubble is already visible
	if dialogue_ui.visible:
		dialogue_ui.skip_or_close()
			# If it just closed, restore movement
		if not dialogue_ui.visible and player:
			player.can_move = true
		return
		# Otherwise start new dialogue
	dialogue_ui.show_text(dialogue_text)
	if player:
		player.can_move = false


var typing := false
var full_text := ""
var text_speed := 0.03  # seconds per character

func type_text(label: Label, text: String) -> void:
	typing = true
	full_text = text
	label.text = ""
	for i in text.length():
		label.text += text[i]
		await get_tree().create_timer(text_speed).timeout
		if not typing:
			break
	
	# If typing was interrupted, instantly finish
	label.text = full_text
	typing = false


func add_hard_drive():
	print("Attempting to pick up hard drive")
	GameManager.num_harddrive += 1
	print("Picked up a hard drive!")
	
	if interaction_type == "harddrive":
		queue_free()
