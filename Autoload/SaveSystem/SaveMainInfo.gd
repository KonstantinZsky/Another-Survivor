# Save and load the game using the text or binary resource format.
#
# /!\ This approach is unsafe if players download completed save games from the 
# web. Please read the README and watch the corresponding video about security
# issues.
#extends Node
class_name MainInfo
extends Resource
# You must use the user:// path prefix when saving the player's data.
#
# We removed the extension in this demo to show how to save as text during
# development or in debug builds and binary in the released game.
#
# See the get_save_path() function below.

# Use this to detect old player saves and update their data.
@export var version := 1

# We directly reference the characters stats and inventory in the save game resource.
# When saving this resource, they'll get saved alongside it.
#@export var character: Resource = Character.new()
#@export var inventory: Resource = Inventory.new()
@export var camera : Resource = CameraSave.new()
#@export var asteroids : Resource = AsteroidsSave.new()
@export var player : Resource = PlayerSave.new()
@export var gameObjects : Array[BaseSaveObject] = []

@export var map_name := ""
@export var global_position := Vector2.ZERO

@export var camera_zoom := Vector2.ZERO

#region Нумерация ссылочных объектов
# Отсчет игровых объектов на которые могут быть ссылки в других игровых объектах.
# Порядковый номер играющий роль УИДа. Нужен для правильного восстановления
# объектов при загрузке. Чтобы они сохраняли свои цели
@export var obj_to_link_count : int  = 1 # Нужно устанавливать в 1 для каждой игровой сессии
# 1 это корабль игрока

#endregion

# The next three functions are just to keep the save API inside of the SaveGame resource.
# Note that this has safety issues if players download savegame files from the 
# web. Please see the README and check out the deciated video.
# For a safe alternative, see the function write/load_as_json() below.
func write_savegame(file_name:String) -> bool:
	#var res = ResourceSaver.save(camera,get_save_path(file_name))
	var res = ResourceSaver.save(self,get_save_path(file_name))
	if res != OK:
		return false
	else:
		return true


static func save_exists(file_name:String) -> bool:
	return ResourceLoader.exists(get_save_path(file_name))

		
# This function allows us to save and load a text resource in debug builds and a
# binary resource in the released product.
static func get_save_path(file_name:String) -> String:
	var user_dir: String = OS.get_user_data_dir()
	var extension := ".tres" if OS.is_debug_build() else ".res"
	var file_path: String = user_dir + "/" + Settings.game_folder + "/Saves/" + file_name + extension
	return file_path
