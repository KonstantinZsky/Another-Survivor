extends Control

# Почему здесь??!! Ну пусть будет здесь
@export var game_session_scene : PackedScene

@onready var tree_saves : Tree = $CanvasLayer/Panel2/ColorRect_MenuPanel/VBoxContainer2/Tree
var tree_saves_root = null # Нужен для создания списка сохранений, все строки будут дочерними

# Not used here
#@onready var map_preshow : TextureRect = $CanvasLayer/Panel2/ColorRect_MenuPanel/TextureRect

#Чтобы менять видимость
@onready var save_button : Button = $CanvasLayer/Panel2/ColorRect_MenuPanel/VBoxContainer/Button_Save 
@onready var line_edit : HBoxContainer = $CanvasLayer/Panel2/ColorRect_MenuPanel/VBoxContainer2/HBoxContainer_edit
@onready var line_edit_edit : LineEdit = $CanvasLayer/Panel2/ColorRect_MenuPanel/VBoxContainer2/HBoxContainer_edit/LineEdit
# Чтобы label для lineEdit называть соответственно языку
@onready var line_edit_label : Label = $CanvasLayer/Panel2/ColorRect_MenuPanel/VBoxContainer2/HBoxContainer_edit/Label
# Ссылки на кнопки чтобы задать их название соответственно языку
@onready var load_button 	: Button = $CanvasLayer/Panel2/ColorRect_MenuPanel/VBoxContainer/Button_Load 
@onready var delete_button 	: Button = $CanvasLayer/Panel2/ColorRect_MenuPanel/VBoxContainer/Button_Delete 
@onready var close_button 	: Button = $CanvasLayer/Panel2/ColorRect_MenuPanel/VBoxContainer/Button_Close 

# Не показывать фон и миникарты если строка не выбрана
var save_selected : bool = false

# Миникарта как текстура
@onready var minimap_texture = $CanvasLayer/Panel2/ColorRect_MenuPanel/TextureRect_minimap

func _ready():	
	tree_saves_root = tree_saves.create_item()
	
	#map_preshow.texture = null	
	SaveBaseInfo.read_saves()	
	var saves_arr = SaveBaseInfo.save_list.values() # А зачем парюсь и в словаре храню?
	for save_elem in saves_arr:
		add_single_save_on_form(save_elem)

func add_single_save_on_form(new_save:Dictionary) -> void:
	var new_save_item = tree_saves.create_item(tree_saves_root)
	new_save_item.set_text(0,new_save.save_name) 		# Имя
	new_save_item.set_text(1,_get_string_from_vector_size(new_save.size))# Размер
	new_save_item.set_text(2,str(int(new_save.level)))	# Level
	new_save_item.set_text(3,new_save.save_time) 		# Время
	new_save.button_link = new_save_item

func refresh_current_save_in_ui_list(save_dat:Dictionary) -> void:
	var item_save_selected = tree_saves.get_selected()
	if item_save_selected == null:
		item_save_selected = save_dat.button_link
	item_save_selected.set_text(0,save_dat.save_name) 		# Имя
	item_save_selected.set_text(1,_get_string_from_vector_size(save_dat.size))# Размер
	item_save_selected.set_text(2,str(int(save_dat.level)))	# Level
	item_save_selected.set_text(3,save_dat.save_time) 		# Время

func _get_string_from_vector_size(f_sz:Vector2) -> String:
	return str(f_sz.x) + " x " + str(f_sz.y) 

func _on_tree_saves_item_activated():
	var item_save_selected = tree_saves.get_selected()
	if !item_save_selected:
		return
	var save_dat = SaveBaseInfo.save_list[item_save_selected.get_text(0)]
	line_edit_edit.text = save_dat.save_name
	SaveBaseInfo._save_light_data = save_dat.duplicate(true)
	#if save_dat.bg_picture == 1:
	#	map_preshow.texture = SaveBaseInfo.texture_preshow1
	
	var pic_path = SaveBaseInfo.get_save_path() + save_dat.save_name + ".png"
	
	var image = Image.load_from_file(pic_path)
	var texture = ImageTexture.create_from_image(image)	
	minimap_texture.texture = texture
	if !save_selected:
		minimap_texture.visible = true

func _on_button_load_pressed():
	if SaveBaseInfo._save_light_data.has("main_save_file"):
		SaveBaseInfo.load_savegame_main_info(SaveBaseInfo._save_light_data.main_save_file)
		SceneControl._it_is_load = true
		switch_load_visibility()
		SceneControl.load_game_session() 
		#await get_tree().change_scene_to_packed(game_session_scene)
		#await RenderingServer.frame_post_draw
		##UI_Signals.test_zoom.emit(false)
		##UI_Signals.save_menu_closed.emit()
		#get_tree().paused = false

func switch_load_visibility() -> void:
	$CanvasLayer.visible = !$CanvasLayer.visible
	SceneControl.save_menu_opened = !SceneControl.save_menu_opened
	if SceneControl.game_session_active:
		save_button.visible = true
	else:
		save_button.visible = false
		
	#$".".visible = !$".".visible

func _on_button_close_pressed():
	#UI_Signals.save_menu_closed.emit()
	switch_load_visibility()

func _on_button_delete_pressed():
	if SaveBaseInfo._save_light_data == {}:
		return
	# Удаляем базовый файл сохранения
	SaveBaseInfo.delete_save_file(SaveBaseInfo._save_light_data.save_name+".save")
	# Удаляем основной файл сохранения
	SaveBaseInfo.delete_save_file(SaveBaseInfo._save_light_data.main_save_file+".tres")
	# Удаляем картинку скриншота
	SaveBaseInfo.delete_save_file(SaveBaseInfo._save_light_data.main_save_file+".png")	
	#map_preshow.texture = null
	SaveBaseInfo.save_list.erase(SaveBaseInfo._save_light_data.save_name)
	#SaveBaseInfo._save_light_data.button_link.queue_free()
	SaveBaseInfo._save_light_data = {}
	tree_saves.get_selected().free()
	save_selected = false
	minimap_texture.visible = false

func _on_button_save_pressed():
	# Need game session to save
	if !SceneControl.game_session_active:
		return
	var save_name : String = line_edit_edit.text
	if save_name == "" :
		#ok_canvas.visible = true
		return
	var name_used : bool = SaveBaseInfo.check_save_name(save_name)
	if name_used:
		# Customize our Modal's texts
		Confirmation.customize(
			"",
			Settings.translate_to_local("File with the same name already \n exists, replace it?","Файл с таким именем уже есть \n заменить его?"),
			Settings.translate_to_local("Yes","Да"),
			Settings.translate_to_local("No","Нет")
		)
		
		# Call the coroutine
		var is_confirmed = await Confirmation.prompt(true)
		
		# If we're confirmed, quit the game
		if is_confirmed:
			get_tree().current_scene.make_save(line_edit_edit.text,true)
			return

	get_tree().current_scene.make_save(line_edit_edit.text,false)

func _on_canvas_layer_visibility_changed():
	tree_saves.set_column_title ( 0, Settings.translate_to_local("Name","Имя") )
	tree_saves.set_column_title ( 1, Settings.translate_to_local("Size","Размер") )
	tree_saves.set_column_title ( 2, Settings.translate_to_local("Type","Тип") )
	tree_saves.set_column_title ( 3, Settings.translate_to_local("Date","Дата") )
