class_name Interactable extends Area2D

# Would need to code for switches, buttons, NPC dialogue triggers.
@export var interact_note_text: String = "" # for KEY or dialogue
@export var interaction_type: String = "Basic" # can only be note, door, npc, or harddrive

'''@onready var envelope = $LetterSprite
@onready var note_ui = $NoteUI
@onready var note_label = $NoteUI/NoteTexture/NoteLabel
@onready var note_texture = $NoteUI/NoteTexture
'''
@onready var envelope = $LetterSprite if has_node("LetterSprite") else null
@onready var note_ui = $NoteUI if has_node("NoteUI") else null
@onready var note_label = $NoteUI/NoteTexture/NoteLabel if has_node("NoteUI/NoteTexture/NoteLabel") else null
@onready var note_texture = $NoteUI/NoteTexture if has_node("NoteUI/NoteTexture") else null


func _ready():
	if note_ui:
		note_ui.visible = false
	#note_ui.visible = false


func interact():
	match interaction_type:
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
			pass


func toggle_note():
	if note_ui == null:
		return  # Not a note-type interactable
	
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

'''
# ----- CODE FOR NOTE # CODE FOR NOTE # CODE FOR NOTE # CODE FOR NOTE ------ #
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
'''

func _on_note_area_2d_body_entered(body: Node):
	if body.name == "Player":
		envelope.play("Open")

func _on_note_area_2d_body_exited(body: Node):
	if body.name == "Player":
		envelope.play("Closed")

# ------- CODE FOR KEY # CODE FOR KEY # CODE FOR KEY # CODE FOR KEY -------- #
func add_key():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.num_keys += 1
		print("Picked up a key! Total keys:", player.num_keys)
		queue_free()

# ------ CODE FOR DOOR # CODE FOR DOOR # CODE FOR DOOR # CODE FOR DOOR ----- #
func try_open_door():
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	
	if player.num_keys > 0:
		player.num_keys -= 1
		print("Door opened! Keys left:", player.num_keys)
	
	# Play animation if this interactable has one
		if has_node("AnimatedSprite2D"):
			var anim = $AnimatedSprite2D
			anim.play("Open")
		
		# Disable collision so player can walk through
			if has_node("CollisionShape2D"):
				$CollisionShape2D.disabled = true
	
			# Wait for animation to finish, then remove door
			await anim.animation_finished
			queue_free()
		else:
			# Fallback if no animation exists
			queue_free()
	else:
		print("Door is locked. You need a key.")
		
		
# -------- CODE FOR DIALOGUE # CODE FOR DIALOGUE # CODE FOR DIALOGUE ------- #
func start_dialogue():
	pass
