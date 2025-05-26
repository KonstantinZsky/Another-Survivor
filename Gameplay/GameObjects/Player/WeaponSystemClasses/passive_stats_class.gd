class_name PassiveStatsClass
extends Resource

@export var current_level : int = 0

@export var picture : Texture2D

@export var global_damage_modifire_per_level : float = 1.0
@export var global_cooldown_modifire_per_level : float = 1.0
@export var global_scale_modifire_per_level  : float = 1.0

@export_multiline var description_en : String = ""
@export_multiline var description_ru : String = ""

func _init(damage : float = 1.0, cooldown : float = 1.0, scale : float = 1.0) -> void:
	global_damage_modifire_per_level = damage
	global_cooldown_modifire_per_level = cooldown
	global_scale_modifire_per_level = scale
	
func get_damage() -> float:
	var res : float = (global_damage_modifire_per_level - 1.0)*float(current_level)
	return res

func get_speed() -> float:
	var res : float = (global_cooldown_modifire_per_level - 1.0)*float(current_level)
	return res

func get_scale() -> float:
	var res : float = (global_scale_modifire_per_level - 1.0)*float(current_level)
	return res
