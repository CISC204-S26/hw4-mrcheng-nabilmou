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
	
	var input_direction = Vector2(
		Input.get_action_strength("Right") - Input.get_action_strength("Left"),
		Input.get_action_strength("Down") - Input.get_action_strength("Up")
		)
	
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
			print("Areas:", areas)
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
