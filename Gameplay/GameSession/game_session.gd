extends Node2D

#@onready var backgroun_layer : CanvasLayer = $CanvasLayer_Backgroun
@onready var backgroun_node : Node2D = $Node2D_Background
@onready var player_link : CharacterBody2D = $Node2D_Player
@onready var camera : Camera2D = $Camera2D
@onready var minimap : Control = $CanvasLayer/Minimap
@onready var game_menu : ColorRect = $CanvasLayer/ColorRect_GameMenu
@onready var enemies_pool : Node2D = $Node2D_EnemiesPool
@onready var powerup_pool : Node2D = $Node2D_PowerupPool

@onready var exp_bar_node : ProgressBar = $CanvasLayer/ProgressBar_PlayerExp

@export var back_level1 : PackedScene
@export var back_level2 : PackedScene

var game_field_size : Vector2 = Vector2(0.0,0.0)

# Skill and passives UI
@onready var skills_ui_arr : Array = [
	{
		icon_node = $CanvasLayer/MarginContainer/VBoxContainer_SkillsPassives/HBoxContainer_Skills/TextureRect_SkillSlot1,
		level_n_node = $CanvasLayer/MarginContainer/VBoxContainer_SkillsPassives/HBoxContainer_Skills/TextureRect_SkillSlot1/Label,
		occupied = false
	},
	{
		icon_node = $CanvasLayer/MarginContainer/VBoxContainer_SkillsPassives/HBoxContainer_Skills/TextureRect_SkillSlot2,
		level_n_node = $CanvasLayer/MarginContainer/VBoxContainer_SkillsPassives/HBoxContainer_Skills/TextureRect_SkillSlot2/Label,
		occupied = false
	},
	{
		icon_node = $CanvasLayer/MarginContainer/VBoxContainer_SkillsPassives/HBoxContainer_Skills/TextureRect_SkillSlot3,
		level_n_node = $CanvasLayer/MarginContainer/VBoxContainer_SkillsPassives/HBoxContainer_Skills/TextureRect_SkillSlot3/Label,
		occupied = false
	}
]
@onready var passives_ui_arr : Array = [
	{
		icon_node = $CanvasLayer/MarginContainer/VBoxContainer_SkillsPassives/HBoxContainer_Passives/TextureRect_PassivelSlot1,
		level_n_node = $CanvasLayer/MarginContainer/VBoxContainer_SkillsPassives/HBoxContainer_Passives/TextureRect_PassivelSlot1/Label,
		occupied = false
	},	
	{
		icon_node = $CanvasLayer/MarginContainer/VBoxContainer_SkillsPassives/HBoxContainer_Passives/TextureRect_PassivelSlot2,
		level_n_node = $CanvasLayer/MarginContainer/VBoxContainer_SkillsPassives/HBoxContainer_Passives/TextureRect_PassivelSlot2/Label,
		occupied = false
	},
	{
		icon_node = $CanvasLayer/MarginContainer/VBoxContainer_SkillsPassives/HBoxContainer_Passives/TextureRect_PassivelSlot3,
		level_n_node = $CanvasLayer/MarginContainer/VBoxContainer_SkillsPassives/HBoxContainer_Passives/TextureRect_PassivelSlot3/Label,
		occupied = false
	},
]

func _ready() -> void:
	
	var level_to_Load : int = 0
	
	# Need to load/select level first
	if SceneControl._it_is_load:	
		level_to_Load = int(SaveBaseInfo._save_light_data.level)
	else:
		level_to_Load = int(Settings.settings_global.new_level_number)					

	match level_to_Load:
		1:
			game_field_size = SceneControl.lvl1_game_field_size
			backgroun_node.add_child(back_level1.instantiate())
			Settings.settings_global.new_level_number = 1
		2:
			game_field_size = SceneControl.lvl2_game_field_size
			backgroun_node.add_child(back_level2.instantiate())	
			Settings.settings_global.new_level_number = 2					
					
	SceneControl.player_link = player_link
	
	minimap.game_field_size = game_field_size
	minimap.camera_node = camera
	minimap.my_init(camera.zoom)		
	
	minimap_LeftTopPoint = minimap.position + minimap.minimap_parallelogram.position
	minimap_RightBotPoint  = minimap_LeftTopPoint + minimap.minimap_parallelogram.size
	minimap_Inner_LeftTopPoint = minimap.minimap_parallelogram.position
	minimap_Inner_RightBotPoint = minimap.minimap_parallelogram.position + minimap.minimap_parallelogram.size		
	
	# Need to do after minimap is ready
	enemies_pool.init(self)
	powerup_pool.init(self)
		
	camera.camera_limits = game_field_size	
	camera.init_on_minimap(minimap)	
	
	player_link.init(self)
	#player_link.init_on_minimap(minimap)	
	
	SceneControl.game_session = self
	
	# Loading objects if it is load
	if SceneControl._it_is_load:
		camera.position = SaveBaseInfo._save_to_load.camera.position
		player_link.position = SaveBaseInfo._save_to_load.player.position		
				
		# Корабль игрока всегда может быть целью, у него номер 1
		SaveBaseInfo.add_linkable(player_link)
			
		# Загружаем игровые объекты без связей
		for item in SaveBaseInfo._save_to_load.gameObjects:
			item.on_load_game(self)
			#var scene = load(item.scene_path) as PackedScene
			#var restored_node = scene.instantiate()
			#self.add_child(restored_node)
			#restored_node.init_get_info(self)
			#restored_node.on_load_game(item)
			#restored_node.add_to_group("to_save")
			
		# Теперь можно пройти по объектам и восстановить связи если нужно.
		# Функция on_load_game_linking будет пустая если не нужно,
		# объекты на которые может быть ссылка находятся в словаре SaveBaseInfo.linkable_loaded
		get_tree().call_group("to_save","on_load_game_linking")	
					
		SceneControl._it_is_load = false	
		SceneControl.current_scene_state = SceneControl.MySceneState.GAME_PAUSE		
		#game_menu.toggle_pause()
		camera.toggle_pause()
	
	# Show on minimap if in pause
	player_link._physics_process(0.0)

@onready var new_level_panel : CanvasLayer = $CanvasLayer_NewLevel
func new_level(variants : Array) -> void:
	new_level_panel.new_level( variants )
func upgrade_chosen(variant) -> void:
	player_link.upgrade_chosen(variant)


@onready var game_lost_panel : ColorRect = $CanvasLayer_GameLost/ColorRect_BackGround

func game_lost() -> void:
	game_lost_panel.game_lost()

#region Minimap

var minimap_LeftTopPoint : Vector2 = Vector2.ZERO
var minimap_RightBotPoint : Vector2 = Vector2.ZERO
var minimap_Inner_LeftTopPoint : Vector2 = Vector2.ZERO
var minimap_Inner_RightBotPoint : Vector2 = Vector2.ZERO

#  При выходе в меню сохраняем скриншот миникарты, если надо будет сохранить
var last_mm_screenchot : Image = null

var mouse_pressed = false

func make_mm_screenshot() -> void:
	var main_viewport = get_viewport()
	var image_raw = main_viewport.get_texture().get_image()
	last_mm_screenchot = image_raw.get_region(Rect2(minimap.position,minimap.size))	

func _on_minimap_gui_input(event):
	if !camera.free_camera:
		return
	if event is InputEventMouseButton && event.pressed && event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
		mouse_pressed = true
		var local_pos : Vector2 = event.position#-position
		if (local_pos.x >= minimap.minimap_offset.x && local_pos.y >= minimap.minimap_offset.y)&&(local_pos.x <= minimap.minimap_size.x && local_pos.y <= minimap.minimap_size.y):
			#Logging.logg("Minimap coords: "+str(local_pos),Logging.MessageType.DEBUG)
			minimap._set_camera_coords_from_minimap(local_pos)
	if event is InputEventMouseButton && !event.pressed && event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
		mouse_pressed = false
	if event is InputEventMouseMotion && mouse_pressed:
		var local_pos : Vector2 = event.position#-position
		if (local_pos.x >= minimap.minimap_offset.x && local_pos.y >= minimap.minimap_offset.y)&&(local_pos.x <= minimap.minimap_size.x && local_pos.y <= minimap.minimap_size.y):
			#Logging.logg("Minimap coords: "+str(local_pos),Logging.MessageType.DEBUG)
			minimap._set_camera_coords_from_minimap(local_pos)	

# Общий ввод на сцене, пока нужен только для плавного движения рамки камеры на миникарте
func _on_control_gui_catch_gui_input(event):
	# Клики вне игровых объектов
	if event is InputEventMouseButton && !event.pressed && event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
		Logging.logg("Unclick signal",Logging.MessageType.DEBUG)	
	
	#Logging.logg("Main field: "+str(event.position),Logging.MessageType.DEBUG)
	if !mouse_pressed: # Смотрим только случай когда клавиша была зажата в поле миникамеры
		return
		# Клавишу отжали, дальше не следим
	if event is InputEventMouseButton && !event.pressed && event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
		mouse_pressed = false
		return
	# Клавиша зажата, надо двигать рамку камеры по миникарте
		# Нужны 2 крайние координаты миникарты чтобы задать местопложение рамки
		# var minimap_LeftTopPoint 
		# var minimap_RightBotPoint	
	var x_changed : bool = false
	var y_changed : bool = false
	var new_frame_pos : Vector2 = event.position - minimap_LeftTopPoint + minimap.minimap_offset
	
	#Logging.logg("Out slip: "+str(new_frame_pos),Logging.MessageType.DEBUG)
	# Ну и тут просто 4 варианта выхода за пределы миникарты
	if event.position.x < minimap_LeftTopPoint.x : # Выход за пределы миникарты влево
		# Координата для отправки - из размера миникарты, обрезанного офсетами
		new_frame_pos.x = minimap_Inner_LeftTopPoint.x 
		x_changed = true
	elif event.position.x > minimap_RightBotPoint.x: # Выход за пределы миникарты направо
		new_frame_pos.x = minimap_Inner_RightBotPoint.x
		x_changed = true
		
	if event.position.y < minimap_LeftTopPoint.y : # Выход за пределы миникарты вверх
		# Координата для отправки - из размера миникарты, обрезанного офсетами
		new_frame_pos.y = minimap_Inner_LeftTopPoint.y
		y_changed = true
	elif event.position.y > minimap_RightBotPoint.y: # Выход за пределы миникарты вниз
		new_frame_pos.y = minimap_Inner_RightBotPoint.y
		y_changed = true		

	if x_changed || y_changed:
		#Logging.logg("Out slip: "+str(new_frame_pos),Logging.MessageType.DEBUG)
		minimap._set_camera_coords_from_minimap(new_frame_pos)	
			
#endregion
	
func make_save(save_name:String,resave:bool):
	
	#var file_name = "Save" + str(Logging.getIntTime())
	var file_name = save_name
	#SaveBaseInfo.last_save_number += 1
	var current_time = Logging.getFormattedDateTime()
	var full_save_name = file_name #+"_"+current_time
	var new_dict = SaveBaseInfo.save_template.duplicate(true)
	SaveBaseInfo._save_light_data = new_dict
	
	SaveBaseInfo._save_to_load.camera_zoom = camera.zoom
	
	# Сохраняем ировые объекты
	var gameObjects : Array[BaseSaveObject] = []
	get_tree().call_group("to_save","on_save_game",gameObjects)
	SaveBaseInfo._save_to_load.gameObjects = gameObjects		
	SaveBaseInfo._save_to_load.player.position = player_link.position

	SaveBaseInfo._save_light_data.size = game_field_size
	SaveBaseInfo._save_light_data.save_name = file_name
	SaveBaseInfo._save_light_data.save_time = current_time
	SaveBaseInfo._save_light_data.level = Settings.settings_global.new_level_number
	SaveBaseInfo._save_light_data.main_save_file = full_save_name
	SaveBaseInfo._save_light_data.camera_pos = camera.position
	var base_inf_saved = SaveBaseInfo.save_save(SaveBaseInfo._save_light_data)
	SaveBaseInfo._save_to_load.camera.position = camera.position
	var main_inf_saved = SaveBaseInfo._save_to_load.write_savegame(full_save_name)
	
	# Сохраняю скриншот миникарты	
	var mm_inf_saved = SaveBaseInfo.save_minimap(last_mm_screenchot,file_name)
	
	# Проверить удачно прошло ли сохранение. Если прошло то вызвать функцию,
	#	которая добавит сохранение в список сохранений.
	if base_inf_saved && main_inf_saved && mm_inf_saved:
		if resave: # Есть сейв с таким названием, не потерям ссылку на UI строку
			SaveBaseInfo._save_light_data.button_link = SaveBaseInfo.save_list[file_name].button_link	
		# Добавляем во внутренний список сохранений
		# (или обновляем если уже есть с таким названием)
		SaveBaseInfo.add_save_to_list(SaveBaseInfo._save_light_data) 
		if resave:	
			# Это пересохранение, обновляем на форме сохранений
			SaveWindow.refresh_current_save_in_ui_list(SaveBaseInfo._save_light_data)
			# Обновим отображение в окне сохранений (миникарта)
			SaveWindow._on_tree_saves_item_activated()		
		else:	
			# Добавляем на форму сохранений  
			SaveWindow.add_single_save_on_form(SaveBaseInfo._save_light_data)																																																																																																																																																																																																																																																																														
		Logging.logg("Game saved! "+full_save_name,Logging.MessageType.INFO)	
