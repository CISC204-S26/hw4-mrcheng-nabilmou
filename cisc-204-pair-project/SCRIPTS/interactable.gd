class_name Interactable extends Area2D


# Would need to code for switches, buttons, NPC dialogue triggers.
@export var interaction_type: String = "Basic" # choose interact type as seen in interact()
@export var npc_animation:  String = "" # set each npc instance's animation
@export var door_animation: String = "" # set each door instance's played animation 
@export var target_scene_path: String # any door can change scene if this is set
@export var keycard_level: int = 0 # set level of keycard instance
@export var required_keycard_level: int = 0 # set level of required keycard to open a door
@export_multiline var note_text: String = "" # set text for each note
@export var dialogue_lines: Array[String] = [] # set dialogue for each npc
@export var target_spawn_id: String
@export var required_keys: int = 0 #Number needed for keys 
@export var unique_id: String = "" #a list of all the data when switching scenes
@export var required_harddrives: int = 0 # set to 5 on the specific NPC instance

# Checks if node with specific name exists, otherwise ignore it
@onready var envelope = $LetterSprite if has_node("LetterSprite") else null
@onready var note_ui = $NoteUI if has_node("NoteUI") else null
@onready var note_label = $NoteUI/NoteTexture/NoteLabel if has_node("NoteUI/NoteTexture/NoteLabel") else null
@onready var note_texture = $NoteUI/NoteTexture if has_node("NoteUI/NoteTexture") else null
@onready var dialogue_ui = get_tree().get_first_node_in_group("dialogue")

# Sounds
@onready var keycard_denied := $KeycardDenied if has_node("KeycardDenied") else null
@onready var keycard_accepted := $KeycardAccepted if has_node("KeycardAccepted") else null
@onready var door_locked := $DoorLocked if has_node("DoorLocked") else null
@onready var door_unlock := $DoorUnlock if has_node("DoorUnlock") else null
@onready var note_pickup := $NotePickup if has_node("NotePickup") else null


@export var is_ending_computer: bool = false #for ending screen
@export var ending_sounds: Array[AudioStream] = []  # drag all your sounds in order
@export var ending_title_screen: PackedScene
var is_actively_interacting: bool = false


func _ready():
	# If this object was already collected/opened, remove it immediately
	#print("DOOR READY: ", name, " | unique_id: ", unique_id, " | collected_ids: ", GameManager.collected_ids)
	if unique_id != "" and unique_id in GameManager.collected_ids:
		queue_free()
		return
	
	if note_ui:
		note_ui.visible = false
		
	_set_door_anim_frame()
	_set_npc_anim()

	GameManager.start_game_bg_music()
	
	# Connect ending computer to dialogue finished signal
	if is_ending_computer and dialogue_ui:
		print("CONNECTING ending computer signal")
		dialogue_ui.dialogue_finished.connect(_ending_dialogue_finished)

# ------------------------INTERACT INTERACT INTERACT ------------------------------------
func interact():
	is_actively_interacting = true
	
	# This cleans the string so "Door" becomes "door"
	var clean_type = interaction_type.strip_edges().to_lower()
	match clean_type:
		"note":
			toggle_note()
		"key":
			add_key()
			show_message("Obtained KEY")
		"keycard":
			add_keycard()
			show_message("Obtained KEYCARD: level " + str(keycard_level))
		"door":
			try_open_door()
		"npc":
			start_dialogue()
			
		"harddrive":
			add_harddrive()
			show_message("Obtained HARD DRIVE")


# -------------- NOTE NOTE NOTE NOTE NOTE NOTE ------------------------------------------
func toggle_note():
	if note_ui == null:
		return  # Not a note-type interactable
	
	var player = get_tree().get_first_node_in_group("player")
	
	if note_ui.visible:
		# ------ CLOSE NOTE ------------
		note_ui.visible = false
		if note_pickup:
			note_pickup.play()
		
		if not dialogue_lines.is_empty() and dialogue_ui != null:
			await get_tree().create_timer(0.3).timeout
			dialogue_ui.show_text(dialogue_lines)
		else:
			if player:
				player.can_move = true
	
	else:
		# --------- OPEN NOTE -----------
		note_label.text = note_text
		note_ui.visible = true
		if player:
			player.can_move = false
		if note_pickup:
			note_pickup.play()


func _on_note_area_2d_body_entered(body: Node):
	if body.name == "Player":
		envelope.play("Open")


func _on_note_area_2d_body_exited(body: Node):
	if body.name == "Player":
		envelope.play("Closed")


# -------------- PICKUPS PICKUPS PICKUPS PICKUPS PICKUPS -------------------------------
func add_key():
	GameManager.num_keys += 1
	GameManager.collected_ids.append(unique_id)
	GameManager.play_pickup_sound()
	queue_free()

func add_keycard():
	if keycard_level == 1:
		GameManager.give_keycard(1)
		GameManager.collected_ids.append(unique_id)
	elif keycard_level == 2:
		GameManager.give_keycard(2)
		GameManager.collected_ids.append(unique_id)
	GameManager.play_pickup_sound()
	queue_free()

func add_harddrive():
	GameManager.num_harddrive += 1
	GameManager.collected_ids.append(unique_id)
	GameManager.play_pickup_sound()
	queue_free()


# --------------------- DOOR DOOR DOOR DOOR DOOR DOOR DOOR -----------------------------
var is_open: bool = false

func try_open_door():
	if is_open:
		return
	
	# ---------- Keycard Doors -----------
	if required_keycard_level > 0:
		if required_keycard_level == 1 and not GameManager.has_keycard1:
			keycard_denied.play()
			show_message("Access Denied: Need LEVEL 1 KEYCARD")
			return
		
		if required_keycard_level == 2 and not GameManager.has_keycard2:
			keycard_denied.play()
			show_message("Access Denied: Need LEVEL 2 KEYCARD")
			return
		
		show_message("Access Granted: Opening Secured Door")
		keycard_accepted.play()
		open_door()
	
	# ---------- Normal Doors ------------
	
	else:
		if GameManager.num_keys < required_keys:
			door_locked.play()
			show_message("Locked: Need " + str(required_keys) + " key(s)")
			return
		show_message("The DOOR opened!")
		door_unlock.play()
		open_door()
	
	
func open_door():
	is_open = true
	
	# Save FIRST before any awaits
	if unique_id != "":
		GameManager.collected_ids.append(unique_id)
	
	GameManager.door_unlocked = true
	
	if has_node("StaticBody2D/CollisionShape2D"):
		$StaticBody2D/CollisionShape2D.set_deferred("disabled", true)
	
	if has_node("NormalDoorSprite"):
		$NormalDoorSprite.play(door_animation)
		await $NormalDoorSprite.animation_finished
	
	if has_node("KeycardDoorSprite"):
		$KeycardDoorSprite.play(door_animation)
		await $KeycardDoorSprite.animation_finished
	
	if target_scene_path != "":
		await get_tree().create_timer(1).timeout
		SceneChanger.change_scene(target_scene_path, target_spawn_id)


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
	var dialogue_seen: bool = false
	if dialogue_ui == null:
		return
	
	if dialogue_ui.visible:
		dialogue_ui.skip_or_close()
		return
	
	# First interaction — play normal dialogue
	if not dialogue_seen:
		dialogue_ui.show_text(dialogue_lines)
		dialogue_seen = true
		return
	
	# Second interaction onwards — check harddrives
	if required_harddrives > 0 and GameManager.num_harddrive < required_harddrives:
		show_message("You need " + str(required_harddrives) + " Hard Drives to proceed. [" + str(GameManager.num_harddrive) + "/" + str(required_harddrives) + "]")
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
	
# This lets you show generalized messages in the dialogue text
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


# ---------------------ENDING + AUDIO----------------------------------------
func _ending_dialogue_finished():
	if not is_ending_computer:
		return
	
	if not is_actively_interacting:
		return
	
	if required_harddrives > 0 and GameManager.num_harddrive < required_harddrives:
		is_actively_interacting = false
		return
	
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.can_move = false
	
	GameManager.bg_music.stop()
	GameManager.bg_music2.stop()
	
	await SceneChanger.fade_out()
	
	# Sound 1 - plays once
	var audio1 = AudioStreamPlayer.new()
	add_child(audio1)
	audio1.stream = ending_sounds[0]
	audio1.volume_db = 0.0
	audio1.play()
	await audio1.finished
	audio1.queue_free()
	
	# Sound 2 - plays once
	var audio2 = AudioStreamPlayer.new()
	add_child(audio2)
	audio2.stream = ending_sounds[1]
	audio2.volume_db = 0.0
	audio2.play()
	await audio2.finished
	audio2.queue_free()
	
	# Sound 3 - plays forever
	var audio3 = AudioStreamPlayer.new()
	add_child(audio3)
	audio3.stream = ending_sounds[2]
	audio3.volume_db = 0.0
	audio3.play()
	
	# Show ending screen
	await get_tree().create_timer(1.0).timeout
	var ending = ending_title_screen.instantiate()
	get_tree().get_root().add_child(ending)
	SceneChanger.fade_rect.visible = false
