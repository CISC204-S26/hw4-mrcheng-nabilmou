extends CanvasLayer

@onready var main_menu_button = $VBoxContainer/MainMenu
@onready var quit_button = $VBoxContainer/Quit

@export var main_menu_scene: String = "res://SCENES/UI_SCREENS/MenuUI.tscn"

func _ready():
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_main_menu_pressed():
	await SceneChanger.fade_out()
	get_tree().change_scene_to_file(main_menu_scene)

func _on_quit_pressed():
	get_tree().quit()
