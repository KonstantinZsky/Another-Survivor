extends Control

# Reference of our ConfirmationModal scene from our scene tree
#@onready var conf: ConfirmationModal = $Control_Confirmation

@onready var main_menu : CanvasLayer = $CanvasLayer_MainMenu
@onready var options : CanvasLayer = $CanvasLayer_Options
@onready var new_game : CanvasLayer = $CanvasLayer_NewGame


func _switch_current_panel(cur_p : SceneControl.MySceneState) -> void:
	match cur_p:
		SceneControl.MySceneState.MAIN_MENU:
			main_menu.visible = true	
			options.visible = false
			new_game.visible = false
			SceneControl.current_scene_state = SceneControl.MySceneState.MAIN_MENU
		SceneControl.MySceneState.MAIN_MENU_OPTIONS:
			main_menu.visible = false	
			options.visible = true
			new_game.visible = false
			SceneControl.current_scene_state = SceneControl.MySceneState.MAIN_MENU_OPTIONS
		SceneControl.MySceneState.MAIN_MENU_LEVEL:
			main_menu.visible = false	
			options.visible = false
			new_game.visible = true
			SceneControl.current_scene_state = SceneControl.MySceneState.MAIN_MENU_LEVEL

var _settings_local : Dictionary = {
	filePathMy = "Settings",
	resolution = Vector2(1920, 1080),
	texture_filtering = "Nearest", 
	fullscreen = false, 
	vsync = false,
	language = "ru"}

func _ready() -> void:
	
	Settings.loadGlobalSettings()
	_settings_local = Settings.settings_global.duplicate(true)
	#map_center = _settings_local.resolution/2.0
	Logging.logg(str(_settings_local.resolution),Logging.MessageType.INFO)
	
	DisplayServer.window_set_size(_settings_local.resolution)
	if _settings_local.fullscreen :
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else :
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)	
	if _settings_local.vsync :
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else :
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)	
	#!!!
	TranslationServer.set_locale(_settings_local.language)
	
	selected_new_level.select(Settings.settings_global.new_level_number-1)

#region Main menu

func _unhandled_key_input(event: InputEvent) -> void:
	
	# If save menu opened - close it
	if SceneControl.save_menu_opened:
		SaveWindow.switch_load_visibility()
		return	
	
	# Using the ESC Key event
	if event.is_action_pressed("ui_cancel"):
		if !SceneControl.current_scene_state == SceneControl.MySceneState.MAIN_MENU:
			_switch_current_panel(SceneControl.MySceneState.MAIN_MENU)
			return
		# Customize our Modal's texts
		Confirmation.customize(
			Settings.translate_to_local("Are you certain?","Вы уверены?"),
			Settings.translate_to_local("This will close the game.","Игра будет закрыта."),
			Settings.translate_to_local("Quit Game","Выйти из игры"),
			Settings.translate_to_local("Back","Назад")
		)
		
		# Call the coroutine
		var is_confirmed = await Confirmation.prompt(true)
		
		# If we're confirmed, quit the game
		if is_confirmed:
			get_tree().quit()
			

func _on_button_new_game_pressed() -> void:
	_switch_current_panel(SceneControl.MySceneState.MAIN_MENU_LEVEL)

func _on_button_load_pressed() -> void:
	SaveWindow.switch_load_visibility()

func _on_button_options_pressed() -> void:
	_switch_current_panel(SceneControl.MySceneState.MAIN_MENU_OPTIONS)

func _on_button_quit_pressed() -> void:
	# Customize our Modal's texts
	Confirmation.customize(
		Settings.translate_to_local("Are you certain?","Вы уверены?"),
		Settings.translate_to_local("This will close the game.","Игра будет закрыта."),
		Settings.translate_to_local("Quit Game","Выйти из игры"),
		Settings.translate_to_local("Back","Назад")
	)
	
	# Call the coroutine
	var is_confirmed = await Confirmation.prompt(true)
	
	# If we're confirmed, quit the game
	if is_confirmed:
		get_tree().quit()

#endregion

#region Options

func _on_button_back_pressed() -> void:
	_settings_local = Settings.settings_global.duplicate(true)
	_switch_current_panel(SceneControl.MySceneState.MAIN_MENU)

# При видимости настроек обновляем информацию о настройках, для каждого элемента отдельно
# Здесь список разрешений
# Путь хранится в описании сигнала, для чистоты кода, путь:
#CanvasLayer_Options/ColorRect_Options/ColorRect_Video/VBoxContainer/HBoxContainer_Resolution/OptionButton_Res
func _on_option_button_res_visibility_changed(option_button_path) -> void:
	var option_button : OptionButton = get_node(option_button_path)
	if not option_button.visible: # обновляем информацию, когда становится видимым
		return		
	var res_selected : int = 0
	var tst = _settings_local.resolution.x
	match int(tst) :
		1280 : res_selected = 1
		1920 : res_selected = 0
	option_button.selected = res_selected

func _on_option_button_res_item_selected(_index: int) -> void:
	match int(_index) :
		1: _settings_local.resolution = Vector2(1280,720)
		0: _settings_local.resolution = Vector2(1920,1080)

# При видимости настроек обновляем информацию о настройках, для каждого элемента отдельно
# Здесь список фильтраций текстур
# Путь хранится в описании сигнала, для чистоты кода, путь:
#CanvasLayer_Options/ColorRect_Options/ColorRect_Video/VBoxContainer/HBoxContainer_TextureFilter/OptionButton_tex
func _on_option_button_tex_visibility_changed(option_button_path) -> void:
	var option_button : OptionButton = get_node(option_button_path)
	if not option_button.visible: # обновляем информацию, когда становится видимым
		return		
	var res_selected : int = 0
	var tst = _settings_local.texture_filtering
	match String(tst) :
		"Nearest" : res_selected = 0
		"Linear" : res_selected = 1
	option_button.selected = res_selected

# При изменении фильтраций текстур сохраняем во временных настройках
func _on_option_button_tex_item_selected(_index: int) -> void:
	match int(_index) :
		0: _settings_local.texture_filtering = "Nearest"
		1: _settings_local.texture_filtering = "Linear"

# При видимости настроек обновляем информацию о настройках, для каждого элемента отдельно
# Здесь полный экран
# Путь хранится в описании сигнала, для чистоты кода, путь:
#CanvasLayer_Options/ColorRect_Options/ColorRect_Video/VBoxContainer/CheckBox_FullScreen
func _on_check_box_full_screen_visibility_changed(option_button_path) -> void:
	var check_box : CheckBox = get_node(option_button_path)
	if not check_box.visible: # обновляем информацию, когда становится видимым
		return		
	check_box.button_pressed = _settings_local.fullscreen

# При изменении полного экрана сохраняем во временных настройках
func _on_check_box_full_screen_toggled(toggled_on: bool) -> void:
	_settings_local.fullscreen = toggled_on

# При видимости настроек обновляем информацию о настройках, для каждого элемента отдельно
# Здесь vsync
# Путь хранится в описании сигнала, для чистоты кода, путь:
#CanvasLayer_Options/ColorRect_Options/ColorRect_Video/VBoxContainer/CheckBox_VSync
func _on_check_box_v_sync_visibility_changed(option_button_path) -> void:
	var check_box : CheckBox = get_node(option_button_path)
	if not check_box.visible: # обновляем информацию, когда становится видимым
		return		
	check_box.button_pressed = _settings_local.vsync

# При изменении vsync сохраняем во временных настройках
func _on_check_box_v_sync_toggled(button_pressed: bool) -> void:
	_settings_local.vsync = button_pressed

# При видимости настроек обновляем информацию о настройках, для каждого элемента отдельно
# Здесь список языков
# Путь хранится в описании сигнала, для чистоты кода, путь:
#CanvasLayer_Options/ColorRect_Options/ColorRect_Game/HBoxContainer_Language/OptionButton_Lang
func _on_option_button_lang_visibility_changed(option_button_path) -> void:
	var option_button : OptionButton = get_node(option_button_path)
	if not option_button.visible: # обновляем информацию, когда становится видимым
		return		
	var res_selected : int = 0
	var tst = _settings_local.language
	match tst:
		"en" : res_selected = 0
		"ru" : res_selected = 1
	option_button.selected = res_selected

# При изменении языка сохраняем во временных настройках
func _on_option_button_lang_item_selected(_index: int) -> void:
	match int(_index) :
		0: _settings_local.language = "en"
		1: _settings_local.language = "ru"

func _on_button_save_pressed() -> void:
	if !Settings.check_if_settings_changed(_settings_local):
		Logging.logg("Опции закрыты",Logging.MessageType.INFO)	
		_switch_current_panel(SceneControl.MySceneState.MAIN_MENU)	
		return	
	
	# Customize our Modal's texts
	Confirmation.customize(
		Settings.translate_to_local("Options changed","Настройки изменены"),
		Settings.translate_to_local("Save changes?","Сохранить изменения?"),
		Settings.translate_to_local("Save","Сохранить"),
		Settings.translate_to_local("Back","Назад")
	)
	
	# Call the coroutine
	var is_confirmed = await Confirmation.prompt(true)
	
	# If we're confirmed, save options
	if is_confirmed:
		# Проверяем соответствия полей, если изменились то выводим сообщение и сохраняем изменение
		if _settings_local.resolution != Settings.settings_global.resolution :
			DisplayServer.window_set_size(_settings_local.resolution)
			#get_tree().reload_current_scene() # не помогает, неверно отрисовывается после изменения размера
			Logging.logg("Разрешение изменено с "+str(Settings.settings_global.resolution)+
				" на "+str(_settings_local.resolution),Logging.MessageType.INFO)
		if _settings_local.fullscreen != Settings.settings_global.fullscreen :
			if _settings_local.fullscreen :
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
				Logging.logg("Переключено на полноэкранный режим",Logging.MessageType.INFO)
			else :
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
				Logging.logg("Переключено на оконный режим",Logging.MessageType.INFO)
		if _settings_local.vsync != Settings.settings_global.vsync :		
			if _settings_local.vsync :
				DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
				Logging.logg("VSync включен",Logging.MessageType.INFO)
			else :
				DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
				Logging.logg("VSync отключен",Logging.MessageType.INFO)	
		if _settings_local.language != Settings.settings_global.language :
			#!!!!!!
			#TranslationServer.set_locale(_settings_local.language)
			get_tree().reload_current_scene() 	# Чтобы то что я кодом задавал сработало заново
												# вызывается ready от main...
			Logging.logg("Язык изменен с "+Settings.settings_global.language+
				" на "+_settings_local.language,Logging.MessageType.INFO)	
		
		Settings.settings_global = _settings_local.duplicate(true)
		Settings.saveGlobalSettings()
		TranslationServer.set_locale(_settings_local.language)
		Logging.logg("Опции закрыты",Logging.MessageType.INFO)	
		#get_tree().reload_current_scene() # does nothing
	else:
		_settings_local = Settings.settings_global.duplicate(true)
	
	_switch_current_panel(SceneControl.MySceneState.MAIN_MENU)
	
#endregion

#region New game

@onready var selected_new_level : OptionButton = $CanvasLayer_NewGame/ColorRect_Options/ColorRect_Video/OptionButton

func _on_button_new_game_back_pressed() -> void:
	_switch_current_panel(SceneControl.MySceneState.MAIN_MENU)

func _on_button_start_pressed() -> void:
	SceneControl.load_game_session()

# Level number selected
func _on_option_button_item_selected(index: int) -> void:
	Settings.settings_global.new_level_number = index + 1
	
#endregion

func _on_vsync_toggled(button_pressed: bool) -> void:
	_settings_local.vsync = button_pressed
