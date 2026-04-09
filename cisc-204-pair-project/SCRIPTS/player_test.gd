extends CharacterBody2D


@onready var interaction_area = $InteractionArea2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


var tile_size := 32
var SPEED := 100

var last_direction := Vector2.DOWN
var reading_note: bool = false
var can_move: bool = true

# For grid movement
var moving := false
var target_position = Vector2.ZERO


func _ready():
	# Align feet to tile grid (4px above bottom)
	position.y = int(position.y / tile_size) * tile_size + tile_size * 2 - 4
	target_position = position
	

func _physics_process(delta: float) -> void:
	if not can_move:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	# If moving, slide toward target position
	if moving:
		var move_vector = (target_position - position)
		if move_vector.length() < SPEED * delta:
			position = target_position
			moving = false
		else:
			position += move_vector.normalized() * SPEED * delta
		update_animation(last_direction)
		return
	
	# Only takes input when not moving
	var input_direction = Vector2.ZERO
	
	if Input.is_action_just_pressed("Right"):
		last_direction = Vector2(1,0)
	elif Input.is_action_just_pressed("Left"):
		last_direction = Vector2(-1,0)
	elif Input.is_action_just_pressed("Down"):
		last_direction = Vector2(0,1)
	elif Input.is_action_just_pressed("Up"):
		last_direction = Vector2(0,-1)
	
	# If holding a move key, keep moving
	if Input.is_action_pressed("Right") and last_direction == Vector2(1,0):
		input_direction = Vector2(1,0)
	elif Input.is_action_pressed("Left") and last_direction == Vector2(-1,0):
		input_direction = Vector2(-1,0)
	elif Input.is_action_pressed("Down") and last_direction == Vector2(0,1):
		input_direction = Vector2(0,1)
	elif Input.is_action_pressed("Up") and last_direction == Vector2(0,-1):
		input_direction = Vector2(0,-1)
	
	if input_direction != Vector2.ZERO:
		var next_position = position + input_direction * tile_size
		# Collision check (TileMap or obstacles)
		target_position = next_position
		last_direction = input_direction
		moving = true
		update_animation(input_direction)
	
	# Save last direction for idle animations
	if input_direction != Vector2.ZERO:
		last_direction = input_direction
	
	# Movement
	velocity = input_direction.normalized() * SPEED
	move_and_slide()
	# Update animations
	update_animation(input_direction)
	

func _process(delta):
	if Input.is_action_just_pressed("Interact"):
		if not reading_note:
			var areas = interaction_area.get_overlapping_areas()
			for area in areas:
				if area is Interactable:
					area.interact()
					if area.interaction_type == "note":
							reading_note = true
							can_move = false
		else: 
			for area in interaction_area.get_overlapping_areas():
				if area is Interactable and area.interaction_type == "note":
					area.toggle_note()
			reading_note = false
			can_move = true


func update_animation(input_vector: Vector2) -> void:
	if input_vector == Vector2.ZERO:
	# IDLE animations
		if last_direction.x < 0:
			sprite.play("Idle_Left")
		elif last_direction.x > 0:
			sprite.play("Idle_Right")
		elif last_direction.y < 0:
			sprite.play("Idle_Backward")
		else:
			sprite.play("Idle_Forward")
	else:
	# WALK animations
		if input_vector.x < 0:
			sprite.play("Walk_Left")
		elif input_vector.x > 0:
			sprite.play("Walk_Right")
		elif input_vector.y < 0:
			sprite.play("Walk_Backward")
		else:
			sprite.play("Walk_Forward")
