class_name BaseSaveObject
extends Resource

# У всех объектов же будет позиция?
@export var pos : Vector2

# Для загрузки соответствующего объекта
#@export var scene_path : String

# Chooses wich object pool is correct
# Need to implement for each object
func on_load_game(game_session : Node2D) -> void:
	pass
