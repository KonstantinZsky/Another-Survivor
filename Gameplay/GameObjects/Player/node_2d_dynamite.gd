extends Node2D

@export var stats : WeaponStatsClass

@export var dynamite_scene : PackedScene

var cur_damage  : float = 40.0
var cur_scale : float = 1.0

var base_attack_timer : float = 5.0
var cur_attack_timer : float = 5.0

var speed_mod : float = 1.0

@onready var attack_timer : Timer = $Timer

func set_new_level(n_l) -> void:
	stats.current_level = n_l
	update_weapon_stats()
	if attack_timer.is_stopped():
		attack_timer.start(cur_attack_timer)

func update_weapon_stats() -> void:
	speed_mod = stats.get_speed()
	cur_attack_timer = base_attack_timer*(1.0/speed_mod)
	cur_scale = stats.get_scale()
	cur_damage = stats.get_damage()

func _on_timer_timeout() -> void:
	var new_dynamite = dynamite_scene.instantiate()	
	
	new_dynamite.my_scale = cur_scale
	new_dynamite.damage = cur_damage
	new_dynamite.position = global_position
	SceneControl.game_session.add_child(new_dynamite)
	#get_tree().add_child(new_ball)
	attack_timer.start(cur_attack_timer)
