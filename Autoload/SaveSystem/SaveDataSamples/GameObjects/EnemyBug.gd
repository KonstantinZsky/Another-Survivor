class_name EnemyBugSave
extends BaseSaveObject

# Осаток ХП
@export var health : float

@export var stats : EnemyClass

# Using enemies pool
func on_load_game(game_session : Node2D) -> void:
	var enemies_pool : Node2D = game_session.enemies_pool
	enemies_pool.activate_enemy(self)
