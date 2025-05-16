extends ColorRect

@onready var canvas : CanvasLayer = $".."

func game_lost() -> void:
	get_tree().paused = true
	canvas.visible = true

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if SceneControl.save_menu_opened:
			SaveWindow.switch_load_visibility()

func _on_button_to_menu_pressed() -> void:
	SceneControl.load_main_menu()

func _on_button_load_pressed() -> void:
	SaveWindow.switch_load_visibility()
