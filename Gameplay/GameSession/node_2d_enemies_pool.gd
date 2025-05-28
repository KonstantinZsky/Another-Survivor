extends Node2D

@export var enemy_scene : PackedScene
@export var max_enemies : int = 50

var enemies_arr : Array = []

func init(game_session : Node2D) -> void:
	for i in max_enemies:
		var new_enemy : CharacterBody2D = enemy_scene.instantiate()
		new_enemy.init_get_info(game_session)
		#new_enemy.hide_on_minimap()
		self.add_child(new_enemy)	
		enemies_arr.push_back(new_enemy)
		
func activate_enemy(data : EnemyBugSave) -> void:
	var enemy_to_activate = enemies_arr.pop_back()
	if !enemy_to_activate: # Pool empty
		return	

	enemy_to_activate.init(data)
	enemy_to_activate.add_to_group("to_save")
	enemy_to_activate.add_to_group("active_enemies")
	# Show on minimap if in pause
	enemy_to_activate.show_on_minimap()
	enemy_to_activate._physics_process(0.0)

	enemy_to_activate.set_physics_process(true)
	enemy_to_activate.visible = true

func get_active_enemies() -> Array:
	return get_tree().get_nodes_in_group("active_enemies")

func kill_enemy(enemy : Node2D) -> void:
	enemy.reset()
	enemy.remove_from_group("to_save")
	enemy.remove_from_group("active_enemies")
	enemies_arr.push_back(enemy)
