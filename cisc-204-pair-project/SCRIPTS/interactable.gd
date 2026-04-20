class_name Interactable extends Area2D

# Would need to code for switches, buttons, NPC dialogue triggers.
@export var interaction_type: String = "Basic" # choose interact type as seen in interact()
@export var npc_animation:  String = "" # set each npc instance's animation
@export var door_animation: String = "" # set each door instance's played animation 
@export var target_scene_path: String # any door can change scene if this is set
@export var keycard_level: int = 0 # set level of keycard instance
@export var required_keycard_level: int = 0 # set level of required keycard to open a door
@export var note_text: String = "" # set text for each note
@export var dialogue_lines: Array[String] = [] # set dialogue for each npc

# Checks if node with specific name exists, otherwise ignore it
@onready var envelope = $LetterSprite if has_node("LetterSprite") else null
@onready var note_ui = $NoteUI if has_node("NoteUI") else null
@onready var note_label = $NoteUI/NoteTexture/NoteLabel if has_node("NoteUI/NoteTexture/NoteLabel") else null
@onready var note_texture = $NoteUI/NoteTexture if has_node("NoteUI/NoteTexture") else null

@onready var dialogue_ui = get_tree().get_first_node_in_group("dialogue")

@export var unique_id: String = "" #a list of all the data when switching scenes


func _ready():
	# If this object was already collected/opened, remove it immediately
	if unique_id != "" and unique_id in GameManager.collected_ids:
		queue_free()
		return
	
	if note_ui:
		note_ui.visible = false
		
	_set_door_anim_frame()
	_set_npc_anim()


# ------------------------INTERACT INTERACT INTERACT ------------------------------------
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
			show_message("Picked up KEY")
		"keycard":
			add_keycard()
			show_message("Picked up KEYCARD: level " + str(keycard_level))
		"door":
			try_open_door()
			#show_message("*Door has been opened*")
		"npc":
			start_dialogue()
		"harddrive":
			add_harddrive()
			show_message("Picked up HARD DRIVE")


# -------------- NOTE NOTE NOTE NOTE NOTE NOTE ------------------------------------------
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


# -------------- PICKUPS PICKUPS PICKUPS PICKUPS PICKUPS -------------------------------
func add_key():
	GameManager.num_keys += 1
	print("Picked up a key! Global keys: ", GameManager.num_keys)
	GameManager.collected_ids.append(unique_id)
	queue_free()


func add_keycard():
	if keycard_level == 1:
		GameManager.give_keycard(1)
		print("Picked up Keycard Level 1")
		print
		GameManager.collected_ids.append(unique_id)
	elif keycard_level == 2:
		GameManager.give_keycard(2)
		print("Picked up Keycard Level 2")
		GameManager.collected_ids.append(unique_id)
	queue_free()


func add_harddrive():
	GameManager.num_harddrive += 1
	GameManager.collected_ids.append(unique_id)
	queue_free()


# --------------------- DOOR DOOR DOOR DOOR DOOR DOOR DOOR -----------------------------
func try_open_door():
	#print("Attempting to open door...")
	
	# ---------- Keycard Doors ---------
	if required_keycard_level > 0:
		if required_keycard_level == 1 and not GameManager.has_keycard1:
			print("LOCKED: Need Keycard Level 1")
			show_message("LOCKED: Need Keycard Level 1")
			return
		
		if required_keycard_level == 2 and not GameManager.has_keycard2:
			show_message("LOCKED: Need Keycard Level 2")
			print("LOCKED: Need Keycard Level 2")
			return
		
		print("KEYCARD ACCEPTED: Opening Secured Door")
		show_message("KEYCARD ACCEPTED: Opening Secured Door")
		open_door()
	
	# ---------- Normal Doors ----------
	else:
		if GameManager.num_keys <= 0:
			#print("Locked: Need KEY")
			show_message("Locked: Need KEY")
			return
		
		#GameManager.num_keys =1
		#print("SUCCESS: Opening Door!")
		show_message("SUCCESS: Opening Door!")
		open_door()


func open_door():
	GameManager.door_unlocked = true
	print(" DOOR UNLOCKED = " ,GameManager.door_unlocked)
	if GameManager.door_unlocked == true:
		if unique_id != "":
			GameManager.collected_ids.append(unique_id)
		
		if has_node("StaticBody2D/CollisionShape2D"):
			$StaticBody2D/CollisionShape2D.set_deferred("disabled", true)
		
		if has_node("NormalDoorSprite"):
			$NormalDoorSprite.play(door_animation)
			await $NormalDoorSprite.animation_finished
		
		if has_node("KeycardDoorSprite"):
			$KeycardDoorSprite.play(door_animation)
			await $KeycardDoorSprite.animation_finished
		
		#else:
			#await $KeycardDoorSprite.animation_finished
			#$StaticBody2D/CollisionShape2D.set_deferred("disabled", true)
			#await $NormalDoorSprite.animation_finished
			
		
	# ------- Scene Changer ----------
	if target_scene_path != "":
		await get_tree().create_timer(1).timeout
		SceneChanger.change_scene(target_scene_path)
	else:
		print("No Target Scene Set!")


func _set_door_anim_frame():
	if door_animation == "":
		return
	
	# Show normal door sprite if it exists
	if has_node("NormalDoorSprite"):
		var anim = $NormalDoorSprite
		if anim.sprite_frames and anim.sprite_frames.has_animation(door_animation):
			anim.animation = door_animation
			anim.frame = 0
			anim.stop()
	
	# Show keycard door sprite if it exists
	if has_node("KeycardDoorSprite"):
		var anim2 = $KeycardDoorSprite
		if anim2.sprite_frames and anim2.sprite_frames.has_animation(door_animation):
			anim2.animation = door_animation
			anim2.frame = 0
			anim2.stop()


# ---------- DIALOGUE DIALOGUE DIALOGUE DIALOGUE DIALOGUE ------------------------------
func start_dialogue():
	#print("dialogue_ui.visible =", dialogue_ui.visible)
	if dialogue_ui == null:
		return
	
	# If bubble is already visible
	if dialogue_ui.visible:
		dialogue_ui.skip_or_close()
		return
		# Otherwise start new dialogue
	dialogue_ui.show_text(dialogue_lines)
	
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
	
#This is to show generalized messages in the dialogue text
# all you need to do is it: show_message("Door opened")
func show_message(text: String):
	if dialogue_ui:
		dialogue_ui.show_text([text] as Array[String])


# ----------------------- NPC NPC NPC NPC NPC NPC ----------------------------------------
func _set_npc_anim():
	if interaction_type.strip_edges().to_lower() != "npc":
		return
	
	if npc_animation == "":
		return
	
	if has_node("NpcSprites"):
		var anim = $NpcSprites
		
		if anim.sprite_frames and anim.sprite_frames.has_animation(npc_animation):
			anim.animation = npc_animation
			anim.play()
