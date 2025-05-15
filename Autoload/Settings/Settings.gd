extends Node

const game_folder : String = "Another Survivor"
var showBoxMessage : bool = true
var showDebug : bool = true

var settings_fields : Array = ["filePathMy","resolution","texture_filtering","fullscreen","vsync","language"]

var settings_global: Dictionary = {
	filePathMy = "Settings",
	resolution = Vector2(1920, 1080), 
	texture_filtering = "Nearest",
	fullscreen = false, 
	vsync = false,
	language = "ru",
# Is set in main menu in new game sub menu, used in _ready in game_session to init level
	new_level_number = 1}
	# Как обозначить какие типы сообщений выводить, а какие нет? Искусственную функцию с числом сделать?
	#	Пусть всё выводится, 2 фалага - выводить ли окошко с сообщениями и выводить ли дебаг и всё

func check_if_settings_changed(local_settings:Dictionary) -> bool:
	var changed = false
	for i in settings_fields.size():
		if local_settings[settings_fields[i]] != settings_global[settings_fields[i]]:
			changed = true
	
	return changed

# Для перевода на английский и русский
#	А если язык меняется?!?! Тогда вывести сообщение что надо перезагрузить
#		а зачем же я делал перевод на лету... ну пусть будет.
func translate_to_local(en_text : String, ru_text : String) -> String:
	match settings_global.language:
		"en" : return en_text
		"ru" : return ru_text
	return en_text

func saveGlobalSettings() -> void:
	saveSettings(settings_global)
	
func loadGlobalSettings() -> void:	
	loadSettings(settings_global)	

func saveSettings(set_dic: Dictionary) -> void:
	Logging.logg("Сохранение настроек",Logging.MessageType.INFO)	
	var user_dir: String = OS.get_user_data_dir()
	var dir_access: DirAccess = DirAccess.open(user_dir)
	if !dir_access:
		Logging.logg("Saving settings - user directory missing",Logging.MessageType.ERROR)
		return

	if !dir_access.dir_exists(game_folder):
		dir_access.make_dir(game_folder)

	var file_path: String = user_dir + "/" + game_folder + "/" + set_dic.filePathMy + ".txt"
	var saveFile: FileAccess = FileAccess.open(file_path, FileAccess.WRITE)
	if !saveFile:
		Logging.logg("Saving settings - error saving settings file",Logging.MessageType.ERROR)
		return

	saveFile.store_string(JSON.stringify(set_dic))
	saveFile.close()

func loadSettings(set_dic: Dictionary) -> void:
	Logging.logg("Загрузка настроек",Logging.MessageType.INFO)
	var user_dir: String = OS.get_user_data_dir()
	var dir_access: DirAccess = DirAccess.open(user_dir)
	if !dir_access:
		Logging.logg("Loading settings - user directory missing",Logging.MessageType.ERROR)
		return

	if !dir_access.dir_exists(game_folder):
		dir_access.make_dir(game_folder)

	var file_path: String = user_dir + "/" + game_folder + "/" + set_dic.filePathMy + ".txt"
	var file_access: FileAccess = FileAccess.open(file_path, FileAccess.READ)
	if !file_access:
		Logging.logg("Loading settings - "+set_dic.filePathMy+" missing",Logging.MessageType.ERROR)
		return

	var dic_key_array: Array = set_dic.keys()

	#while file_access.get_position() < file_access.get_len():
	while not file_access.eof_reached():
		var loadedData = JSON.parse_string(file_access.get_line())

		for dic_key in dic_key_array:
			if typeof(set_dic[dic_key]) == TYPE_VECTOR2:
				set_dic[dic_key] = _string_to_vector2(loadedData[dic_key])
			else:
				set_dic[dic_key] = loadedData[dic_key]

	file_access.close()

func _string_to_vector2(cords : String) -> Vector2:
	cords.replace("(","")
	cords.replace(")","")
	cords.replace(",","")
	var x = cords.left(cords.find(" "))
	var y = cords.right(cords.find(" "))
	return Vector2(int(x),int(y))
