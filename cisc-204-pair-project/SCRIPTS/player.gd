extends CharacterBody2D


@onready var interaction_area = $InteractionArea2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


var SPEED := 100.0
var last_direction := Vector2.DOWN
var reading_note: bool = false
var can_move: bool = true

func _physics_process(delta: float) -> void:
	if not can_move:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	var input_vector = Vector2.ZERO
	if input_vector != Vector2.ZERO:
		last_direction = input_vector
	
	var input_direction = Vector2(
		Input.get_action_strength("Right") - Input.get_action_strength("Left"),
		Input.get_action_strength("Down") - Input.get_action_strength("Up")
	)
	
	#THIS IS THE SAME THING AS ABOVE
	# Horizontal
	'''if Input.is_action_pressed("Left"):
		input_vector.x -= 1
	if Input.is_action_pressed("Right"):
		input_vector.x += 1
	# Vertical
	if Input.is_action_pressed("Up"):
		input_vector.y -= 1
	if Input.is_action_pressed("Down"):
		input_vector.y += 1'''
	
	# Normalize so diagonal movement isn't faster
	input_vector = input_vector.normalized()
	
	velocity = input_direction * SPEED
	#velocity = input_vector * SPEED
	move_and_slide()


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
			sprite.play("Idle_Foward")
		else:
			sprite.play("Idle_Backward")
	#else:
	# WALK animations
		'''if input_vector.x < 0:
			sprite.play("walk_left")
		elif input_vector.x > 0:
			sprite.play("walk_right")
		elif input_vector.y < 0:
			sprite.play("walk_up")
		else:
			sprite.play("walk_down")'''
