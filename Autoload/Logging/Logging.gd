extends Control

@onready var message_box = $CanvasLayer/VBoxContainer
@onready var rich_text_label = $CanvasLayer/VBoxContainer/RichTextLabel

enum MessageType {DEBUG,INFO,WARNING,ERROR}

var message_types = [
	{"type": MessageType.DEBUG,"color": "#c1c1c1",},
	{"type": MessageType.INFO,"color": "#5cb8a5",},
	{"type": MessageType.WARNING,"color": "#f9c74f",},
	{"type": MessageType.ERROR,"color": "#ff6b6b",}
]

var user_data_dir : String = ""
var latest_messages : Array[String] = []
var max_stored_messages = 50 # Для вывода в rich_text_label, в файл без ограничений

func _ready():
	user_data_dir = OS.get_user_data_dir()

func cleanupOldLogs():
	
	var dir_access : DirAccess = DirAccess.open(user_data_dir)

	if !dir_access.dir_exists(Settings.game_folder):
		dir_access.make_dir(Settings.game_folder)

	var log_path = Settings.game_folder + "/Logs"

	if !dir_access.dir_exists(log_path):
		dir_access.make_dir(log_path)

	# Get the date 5 days ago as a Unix timestamp
	var five_days_ago_unix_time = Time.get_unix_time_from_system() - 5 * 24 * 60 * 60

	var log_dir = user_data_dir + "/" + log_path
	
	# Get a list of all files in the StarGameLog folder
	var files = DirAccess.get_files_at(log_dir)

	# Loop through the files and delete those that are older than 5 days
	for file in files:
		# Get the file's modified time as a Unix timestamp
		var modified_time = FileAccess.get_modified_time(log_dir + file)
		if modified_time == "ERROR IN FILE":
			print("Error in cleanupOldLogs: Failed to get modified time for " + file)
			continue

		if modified_time < five_days_ago_unix_time: # The file was modified more than 5 days ago
			var result = dir_access.remove(file)
			if result != OK: # There was an error deleting the file
				print("Error in cleanupOldLogs: Failed to delete " + file)
	
	dir_access.close()

func logg(error_message: String, error_level: MessageType) -> void:
		
	if error_level == MessageType.DEBUG and !Settings.showDebug:
		return
		
	var dir_access : DirAccess = DirAccess.open(user_data_dir)

	if !dir_access.dir_exists(Settings.game_folder):
		dir_access.make_dir(Settings.game_folder)

	var game_log_path = Settings.game_folder + "/Logs"

	if !dir_access.dir_exists(game_log_path):
		dir_access.make_dir(game_log_path)

	var log_dir = user_data_dir + "/" + game_log_path

	var formatted_date : String = getFormattedDate()
	var log_name : String = "Log_" + formatted_date + ".csv"
	var log_path : String = log_dir + "/" + log_name

	var file : FileAccess = null
	if FileAccess.file_exists(log_path):
		file = FileAccess.open(log_path, FileAccess.READ_WRITE) # Просто write очистит файл
	else:
		file = FileAccess.open(log_path, FileAccess.WRITE)	

	var formatted_time : String = getFormattedTime()
	var error_level_string : String = MessageType.keys()[error_level] #.rpad(14,' ') не выравнивается...
	var log_line : String = error_level_string + ";" + formatted_time + ";" + error_message + "\n"
	file.seek_end()
	file.store_string(log_line)

	file.close()

	if !Settings.showBoxMessage:
		return
		
	var message_color = "#ffffff"
	for type in message_types:
		if type["type"] == error_level:
			message_color = type["color"]
			break
	var error_text : String = "[color=" + message_color + "]" + error_level_string + " - " + formatted_time + ": " + error_message + "[/color]\n"

	# Add the latest message to the list of messages
	latest_messages.append(error_text)

	# Limit the maximum number of messages stored
	if len(latest_messages) > max_stored_messages:
		latest_messages.remove_at(0)

	# Update the rich_text_label with the latest messages
	var all_messages : String = ""
	for message in latest_messages:
		all_messages += message
	rich_text_label.bbcode_text = all_messages

func getEnvironmentInfo() -> String:
	# Получаем название операционной системы и преобразуем в строку
	var os_name = str(OS.get_name()).c_escape()

	# Получаем текущую дату и время и преобразуем в строку
	var date_time = str(Time.get_datetime_dict_from_system()).c_escape()

	# Получаем размер экрана и преобразуем в строку 
	var screen_size = str(DisplayServer.screen_get_size()).c_escape()

	# Получаем количество кадров в секунду и преобразуем в строку
	var fps = str(Engine.get_frames_per_second()).c_escape()

	# Получаем модель процессора и преобразуем в строку
	var cpu_model = str(OS.get_model_name()).c_escape()

	# Получаем количество ядер процессора и преобразуем в строку
	var cpu_cores = str(OS.get_processor_count()).c_escape()

	# Получаем количество статической памяти, потребляемой приложением, и преобразуем в строку
	var static_mem = str(OS.get_static_memory_usage()).c_escape()

	# Формируем итоговую строку
	var result_string = os_name+";"+date_time+";"+screen_size+";"+fps+";"+cpu_model+";"+cpu_cores+";"+static_mem
	
	return result_string

func getFormattedDate() -> String:
	# Получаем текущую дату
	var date_dict = Time.get_date_dict_from_system()

	# Создаем строку для вывода даты
	var formatted_date = str(date_dict.year) + "_"

	if date_dict.month < 10:
		formatted_date += "0"
	formatted_date += str(date_dict.month) + "_"

	if date_dict.day < 10:
		formatted_date += "0"
	formatted_date += str(date_dict.day)

	return formatted_date

func getIntTime() -> int:
	var unix_time = Time.get_unix_time_from_system()
	var datetime_dict = Time.get_datetime_dict_from_unix_time(unix_time)
	return Time.get_unix_time_from_datetime_dict ( datetime_dict )

func getFormattedTime() -> String:
	# Получаем текущее время
	var unix_time = Time.get_unix_time_from_system()
	var datetime_dict = Time.get_datetime_dict_from_unix_time(unix_time)

	# Создаем строку для вывода времени
	var formatted_time = ""

	if datetime_dict.hour < 10:
		formatted_time += "0"
	formatted_time += str(datetime_dict.hour) + ":"

	if datetime_dict.minute < 10:
		formatted_time += "0"
	formatted_time += str(datetime_dict.minute) + ":"

	if datetime_dict.second < 10:
		formatted_time += "0"
	formatted_time += str(datetime_dict.second)

	return formatted_time

func getFormattedDateTime() -> String:
	# Получаем текущую дату и время
	var unix_time = Time.get_unix_time_from_system()
	var datetime_dict = Time.get_datetime_dict_from_unix_time(unix_time)

	# Создаем строку для сохранения в файл
	var formatted_date_time = str(datetime_dict.year) + "_"

	if datetime_dict.month < 10:
		formatted_date_time += "0" + str(datetime_dict.month)
	else:
		formatted_date_time += str(datetime_dict.month)

	formatted_date_time += "_"

	if datetime_dict.day < 10:
		formatted_date_time += "0" + str(datetime_dict.day)
	else:
		formatted_date_time += str(datetime_dict.day)

	formatted_date_time += "_"

	if datetime_dict.hour < 10:
		formatted_date_time += "0" + str(datetime_dict.hour)
	else:
		formatted_date_time += str(datetime_dict.hour)

	formatted_date_time += "_"

	if datetime_dict.minute < 10:
		formatted_date_time += "0" + str(datetime_dict.minute)
	else:
		formatted_date_time += str(datetime_dict.minute)

	formatted_date_time += "_"

	if datetime_dict.second < 10:
		formatted_date_time += "0" + str(datetime_dict.second)
	else:
		formatted_date_time += str(datetime_dict.second)

	return formatted_date_time
