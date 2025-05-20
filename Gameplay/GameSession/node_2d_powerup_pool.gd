extends Node2D

@export var powerup_scene : PackedScene
@export var max_powerups : int = 500

var powerups_arr : Array = []

func init(game_session : Node2D) -> void:
	for i in max_powerups:
		var powerup : CharacterBody2D = powerup_scene.instantiate()
		powerup.init_get_info(game_session)
		powerup.hide_on_minimap()
		self.add_child(powerup)	
		powerups_arr.push_back(powerup)
		
func activate_powerup(data : PowerupSave) -> void:
	var powerup_to_activate = powerups_arr.pop_back()
	if !powerup_to_activate: # Pool empty
		return	

	powerup_to_activate.init(data)
	powerup_to_activate.add_to_group("to_save")
	# Show on minimap if in pause
	powerup_to_activate.show_on_minimap()
	powerup_to_activate.move_on_minimap()

	powerup_to_activate.set_physics_process(true)
	powerup_to_activate.visible = true	

func kill_powerup(enemy : Node2D) -> void:
	enemy.reset()
	enemy.remove_from_group("to_save")
	powerups_arr.push_back(enemy)
