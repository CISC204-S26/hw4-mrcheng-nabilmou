extends CanvasLayer

@onready var main_menu_button = $VBoxContainer/MainMenu
@onready var quit_button = $VBoxContainer/Quit
@onready var hover_sound = $HoverSound
@onready var click_sound = $ClickSound


@export var main_menu_scene: String = "res://SCENES/UI_SCREENS/MenuUI.tscn"


func _ready():
	pass


func _on_main_menu_pressed():
	await SceneChanger.fade_out()
	get_tree().change_scene_to_file(main_menu_scene)


func _on_quit_pressed():
	await get_tree().create_timer(.5).timeout
	get_tree().quit()


# ------------------------ SOUNDS SOUNDS SOUNDS -----------------------------------------
func play_hover_sound():
	hover_sound.play()


func play_click_sound():
	click_sound.play()
