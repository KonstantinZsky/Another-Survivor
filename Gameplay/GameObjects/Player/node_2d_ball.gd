extends Node2D

@export var stats : WeaponStatsClass

@export var baseball_ball_scene : PackedScene

var cur_damage  : float = 40.0
var cur_scale : float = 1.0

var base_attack_timer : float = 1.5
var cur_attack_timer : float = 1.5

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
	var new_ball = baseball_ball_scene.instantiate()
	new_ball.speed = new_ball.speed_base*speed_mod
	
	var current_mouse_position = get_global_mouse_position()	
	var controlled_object_pos_on_screen = global_position
	var vector_to_mouse = current_mouse_position-controlled_object_pos_on_screen	
	
	new_ball.direction = vector_to_mouse.normalized()
	new_ball.my_scale = cur_scale
	new_ball.damage = cur_damage
	new_ball.position = global_position
	SceneControl.game_session.add_child(new_ball)
	#get_tree().add_child(new_ball)
	attack_timer.start(cur_attack_timer)
