class_name PowerupSave
extends BaseSaveObject

enum PowerupType {EXPIRIENCE}

# Осаток ХП
@export var type : PowerupType

# Using enemies pool
func on_load_game(game_session : Node2D) -> void:
	var powerup_pool : Node2D = game_session.powerup_pool
	powerup_pool.activate_powerup(self)
