extends CharacterBody2D

@onready var interaction_area = $InteractionArea2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray: RayCast2D = $RayCast2D # Add a RayCast2D node to your player scene!

var tile_size := 32
# Replaced SPEED with move_time. This is how many seconds it takes to move 1 tile.
var move_time := 0.25 

var last_direction := Vector2.DOWN
var reading_note: bool = false
var can_move: bool = true
var moving := false

func _ready():
	# Original feet alignment
	position.y = int(position.y / tile_size) * tile_size + tile_size * 2 - 4
	
	# Keep the raycast from rotating if player is ever rotated
	ray.top_level = true 

func _physics_process(_delta: float) -> void:
	if not can_move or moving:
		return
	
	var input_direction = Vector2.ZERO
	
	# Check inputs (4-way movement, no diagonals)
	if Input.is_action_pressed("Right"):
		input_direction = Vector2.RIGHT
	elif Input.is_action_pressed("Left"):
		input_direction = Vector2.LEFT
	elif Input.is_action_pressed("Down"):
		input_direction = Vector2.DOWN
	elif Input.is_action_pressed("Up"):
		input_direction = Vector2.UP
	
	if input_direction != Vector2.ZERO:
		last_direction = input_direction
		update_animation(input_direction)
		move_to_grid(input_direction)
	else:
		# If no input is pressed, play idle animation based on last_direction
		update_animation(Vector2.ZERO)

func move_to_grid(direction: Vector2) -> void:
	moving = true
	var target_position = position + (direction * tile_size)
	
	# Snap the raycast to the player, point it at the next tile, and update
	ray.global_position = global_position
	ray.target_position = direction * tile_size
	ray.force_raycast_update()
	
	# If there is NO collision wall in the way, move!
	if not ray.is_colliding():
		var tween = create_tween()
		# Smoothly slide the position to the target over 'move_time' seconds
		tween.tween_property(self, "position", target_position, move_time)
		await tween.finished
	
	moving = false


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
