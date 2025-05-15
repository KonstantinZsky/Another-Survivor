extends ColorRect

@onready var game_session : Node2D = $"../.."

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		toggle_pause()
		
func toggle_pause() -> void:
	var pause : bool = get_tree().paused
	# If game paused normally - do nothing
	if (pause && !game_session.menu_paused):
		return
	# If save menu opened - close it
	if SceneControl.save_menu_opened:
		SaveWindow.switch_load_visibility()
		return
		
	game_session.make_mm_screenshot() # Minimap screenshot for save
	pause = !pause
	game_session.menu_paused = pause
	get_tree().paused = pause
	self.visible = pause

func _on_button_resume_pressed() -> void:
	toggle_pause()

func _on_button_save_load_pressed() -> void:
	SaveWindow.switch_load_visibility()

func _on_button_quit_pressed() -> void:
	# Customize our Modal's texts
	Confirmation.customize(
		Settings.translate_to_local("Quit to main menu?","Выйти в главное меню?"),
		Settings.translate_to_local("All unsaved progress will be lost.","Весь не сохраненный прогресс \nбудет потерян."),
		Settings.translate_to_local("Yes","Да"),
		Settings.translate_to_local("No","Нет")
	)
	
	# Call the coroutine
	var is_confirmed = await Confirmation.prompt(true)
	
	# If we're confirmed, quit the game
	if is_confirmed:
		SceneControl.load_main_menu()
		#get_tree().paused = false
		#get_tree().change_scene_to_file("res://main.tscn")
