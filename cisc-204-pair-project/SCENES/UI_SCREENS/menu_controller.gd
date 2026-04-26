extends CanvasLayer


@onready var main_buttons = $MainButtons
@onready var settings_panel = $SettingsPanel
@onready var volume_slider = $SettingsPanel/VolumeSlider
@onready var hover_sound = $HoverSound
@onready var click_sound = $ClickSound
@onready var menu_music = $MainMusic


func _ready():
	settings_panel.hide() # hidden by default
	volume_slider.value_changed.connect(_on_volume_changed)
	menu_music.play()

# ----------------- BUTTONS BUTTONS BUTTONS --------------------------------------------
func _on_play_pressed():
	menu_music.stop()
	await get_tree().create_timer(.1).timeout
	get_tree().change_scene_to_file("res://SCENES/OFFICIAL_MAP/Foyer.tscn")

func _on_settings_pressed():
	main_buttons.hide()
	settings_panel.show()

func _on_back_pressed():
	main_buttons.show()
	settings_panel.hide()

func _on_quit_pressed():
	await get_tree().create_timer(.5).timeout
	get_tree().quit()

func _on_volume_changed(value):
	var db = linear_to_db(value / 100.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), db)


# ------------------------ SOUNDS SOUNDS SOUNDS -----------------------------------------
func play_hover_sound():
	hover_sound.play()


func play_click_sound():
	click_sound.play()
