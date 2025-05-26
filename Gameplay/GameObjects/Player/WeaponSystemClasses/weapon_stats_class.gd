class_name WeaponStatsClass
extends Resource

@export var current_level : int = 0

@export var picture : Texture2D

@export var base_damage  : float = 40.0
@export var percent_damage_increase_with_level : float = 1.05
#@export var global_damage_modifire : float = 0.0

@export_multiline var description_en : String = ""
@export_multiline var description_ru : String = ""

func get_damage() -> float:
	var mod = (percent_damage_increase_with_level - 1.0)*float(current_level)
	var val = base_damage * (1+mod) * link_to_global_modifires.global_damage_modifire
	return val

# Attack speed, done via frames per seconds for readability and simplicity
@export var percent_speed_increase_with_level : float = 1.05
#@export var global_cooldown_modifire : float = 0.0

func get_speed() -> float:
	var mod = (percent_speed_increase_with_level - 1.0)*float(current_level)
	var val = (1+mod) * link_to_global_modifires.global_cooldown_modifire
	return val

# Scale used for area of effect modifire
@export var percent_scale_increase_with_level : float = 1.05
#@export var global_scale_modifire : float = 0.0

func get_scale() -> float:
	var mod = (percent_scale_increase_with_level - 1.0)*float(current_level)
	var val = (1+mod) * link_to_global_modifires.global_scale_modifire
	return val

@export var link_to_global_modifires : WeaponGlobalModifiresClass
