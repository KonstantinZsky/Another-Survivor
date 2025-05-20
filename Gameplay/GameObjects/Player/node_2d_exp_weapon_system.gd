extends Node2D

var exp_bar_link : ProgressBar = null

var current_exp = 0.0

func gain_powerup(body) -> void:
	current_exp = current_exp + 3.0
	exp_bar_link.value = current_exp
