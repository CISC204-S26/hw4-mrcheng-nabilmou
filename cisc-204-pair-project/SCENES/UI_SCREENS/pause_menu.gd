extends CanvasLayer


@onready var hover_sound = $HoverSound
@onready var click_sound = $ClickSound


func _ready():
	hide()


func _input(event):
	if event.is_action_pressed("Pause"):
		toggle_pause()


func toggle_pause():
	var new_state = !get_tree().paused
	get_tree().paused = new_state
	visible = new_state 


func _on_resume_button_pressed():
	print("pressed resume")
	toggle_pause()

func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://SCENES/UI_SCREENS/MenuUI.tscn")
	
func _on_quit_button_pressed():
	get_tree().quit()


# ------------------------ SOUNDS SOUNDS SOUNDS -----------------------------------------
func play_hover_sound():
	hover_sound.play()

func play_click_sound():
	click_sound.play()
