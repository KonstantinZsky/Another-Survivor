extends Node

#region Нумерация ссылочных объектов
# Отсчет игровых объектов на которые могут быть ссылки в других игровых объектах.
# Порядковый номер играющий роль УИДа. Нужен для правильного восстановления
# объектов при загрузке. Чтобы они сохраняли свои цели
#var obj_to_link_count : int  = 1 # Нужно устанавливать в 1 для каждой игровой сессии
# 1 это корабль игрока
# После загрузки сохранения - как начать новую нумерацию?
# Перенес в MainInfo

# Здесь будут пары номер - ссылка, чтобы восстанавливать ссылки
var linkable_loaded : Dictionary = {}

func add_linkable( to_add : Node) -> void:
	linkable_loaded[to_add.link_number_self] = to_add
	
func find_linkable( link_num : int ) -> Node:
	if linkable_loaded.has(link_num):
		return linkable_loaded[link_num]
	return null

func reset_linkable_dict() -> void:
	linkable_loaded = {}

# Сразу инкрементируется, так как 1 у корабля игрока
func get_link_number() -> int:
	if _it_is_load:
		# При загрузке все номера возьмутся из сейва
		# тут просто заглушка, чтобы лишний раз не инкрементировать
		return _save_to_load.obj_to_link_count 
	_save_to_load.obj_to_link_count = _save_to_load.obj_to_link_count + 1
	return _save_to_load.obj_to_link_count
	
# Сброс, не нужен?
func reset_link_numertion() -> void:
	_save_to_load.obj_to_link_count = 1
#endregion
	
var _save_to_load : MainInfo = MainInfo.new()

var last_save_number: int = 1

var player : PlayerSave = PlayerSave.new()

#var texture_preshow1 : CompressedTexture2D = load("res://Assets/BackTextures/blue_v1.png")

var save_template: Dictionary = {
	"save_name": "",
	"save_time": "",
	"game_time": 0.0,
	"bg_picture": 0,
	"level" : "",
	"size" : Vector2(0, 0),
	"main_save_file": "",
	"camera_pos": Vector2(0, 0),
	"button_link": null
}

var _it_is_load : bool = false 

var save_list: Dictionary = {}

var _save_light_data : Dictionary = {}
		
#var _selected_save_button = null				
		
func load_savegame_main_info(file_name:String) -> void:
	var save_path := MainInfo.get_save_path(file_name)
	#if ResourceLoader.has_cached(save_path):
		# Once the resource caching bug is fixed, you will only need this line of code to load the save game.
	#	return ResourceLoader.load(save_path, "", 0)
	#return null
	#var test_res_load = ResourceLoader.load(save_path, "", 0)
	#SaveBaseInfo._save_to_load = ResourceLoader.load(save_path, "", 0)
	#camera = SaveBaseInfo._save_to_load
	#_save_to_load = ResourceLoader.load(save_path, "", 0)	
	#_save_to_load = SafeResourceLoader.load(save_path)	
	_save_to_load = ResourceLoader.load(save_path, "", 0)
	if 	_save_to_load == null:
		Logging.logg("Save file: " + save_path + " corrupted!", Logging.MessageType.ERROR)
		
# Проверить есть ли такое название сохранения
func check_save_name(n_chk:String) -> bool:
	return save_list.has(n_chk)		
	
# Получить путь сохранений
func get_save_path() -> String:
	var user_dir: String = OS.get_user_data_dir()
	var file_path: String = user_dir + "/" + Settings.game_folder + "/Saves/"
	return file_path		
		
# Возвращает булевский тип - успешность сохранения
func save_save(set_dic: Dictionary) -> bool:
	Logging.logg("Saving game", Logging.MessageType.INFO)
	var user_dir: String = OS.get_user_data_dir()
	if !create_folder_if_missing(Settings.game_folder + "/Saves"):
		Logging.logg("Error: could not save game", Logging.MessageType.ERROR)
		return false

	var dir_access: DirAccess = DirAccess.open(user_dir + "/" + Settings.game_folder + "/Saves")
	if !dir_access:
		Logging.logg("Error: could not read saves directory", Logging.MessageType.ERROR)
		return false

	var file_path: String = user_dir + "/" + Settings.game_folder + "/Saves/" + set_dic.save_name + ".save"
	var saveFile: FileAccess = FileAccess.open(file_path, FileAccess.WRITE)
	if !saveFile:
		Logging.logg("Saving game - error saving game file",Logging.MessageType.ERROR)
		return false

	saveFile.store_string(JSON.stringify(set_dic))
	saveFile.close()
	return true	

func save_minimap(mm_img : Image, file_name : String) -> bool:
	Logging.logg("Saving minimap", Logging.MessageType.INFO)
	var user_dir: String = OS.get_user_data_dir()
	if !create_folder_if_missing(Settings.game_folder + "/Saves"):
		Logging.logg("Error: could not save minimap", Logging.MessageType.ERROR)
		return false

	var dir_access: DirAccess = DirAccess.open(user_dir + "/" + Settings.game_folder + "/Saves")
	if !dir_access:
		Logging.logg("Error: could not read saves directory", Logging.MessageType.ERROR)
		return false

	var file_path: String = user_dir + "/" + Settings.game_folder + "/Saves/" + file_name + ".png"	
	var s_res = mm_img.save_png(file_path)
	
	if s_res != OK:
		Logging.logg("Saving minimap - error saving minimap file",Logging.MessageType.ERROR)
		return false

	return true		
	

func delete_save_file(f_name : String) -> void:
	Logging.logg("Deleting game"+str(f_name), Logging.MessageType.INFO)
	var user_dir: String = OS.get_user_data_dir()
	var save_dir: String = user_dir + "/" + Settings.game_folder + "/Saves"
	var dir_access: DirAccess = DirAccess.open(save_dir)
	if !dir_access:
		Logging.logg("Error: could not read saves directory", Logging.MessageType.ERROR)
		return
	dir_access.remove(f_name)
	
func read_saves() -> void:
	
	Logging.logg("Reading saves", Logging.MessageType.INFO)
	var user_dir: String = OS.get_user_data_dir()
	if !create_folder_if_missing(Settings.game_folder + "/Saves"):
		Logging.logg("Error: could not read saves", Logging.MessageType.ERROR)
		return 

	var dir_access: DirAccess = DirAccess.open(user_dir + "/" + Settings.game_folder + "/Saves")
	if !dir_access:
		Logging.logg("Error: could not read saves directory", Logging.MessageType.ERROR)
		return 

	var save_files: PackedStringArray = dir_access.get_files()
	for file_name in save_files:
		if file_name.ends_with(".save"):
			var file_access: FileAccess = FileAccess.open(user_dir + "/" + Settings.game_folder + "/Saves/" + file_name, FileAccess.READ)
			if !file_access:
				Logging.logg("Error: could not read save file " + file_name, Logging.MessageType.ERROR)
				continue

			var save_dict: Dictionary = {}
			while not file_access.eof_reached():
				var save_data: Dictionary = JSON.parse_string(file_access.get_line())
							
				for key in save_template.keys():
					if key in save_data:
						if typeof(save_template[key]) == TYPE_VECTOR2:
							save_dict[key] = Settings._string_to_vector2(save_data[key])
						else:
							save_dict[key] = save_data[key]
					else:
						save_dict[key] = save_template[key]
			file_access.close()

			add_save_to_list(save_dict)
			#var save_key: String = "save" + str(last_save_number)
			#save_list[save_key] = save_dict
			#last_save_number += 1

			Logging.logg("Save read: " + save_dict["save_name"], Logging.MessageType.INFO)

func add_save_to_list(new_save:Dictionary) -> void:
	var save_key: String = new_save.save_name
	save_list[save_key] = new_save.duplicate(true)

func create_folder_if_missing(folder_name: String) -> bool:
	Logging.logg("Creating folder if missing: " + folder_name, Logging.MessageType.INFO)
	var user_dir: String = OS.get_user_data_dir()
	var dir_access: DirAccess = DirAccess.open(user_dir)
	if !dir_access:
		Logging.logg("Error: user directory missing", Logging.MessageType.ERROR)
		return false

	if !dir_access.dir_exists(folder_name):
		if !dir_access.make_dir(folder_name) == OK:
			Logging.logg("Error: could not create folder", Logging.MessageType.ERROR)
			return false
		Logging.logg("Folder created: " + folder_name, Logging.MessageType.INFO)
	else:
		Logging.logg("Folder already exists: " + folder_name, Logging.MessageType.INFO)
	return true
