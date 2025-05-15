class_name MyHitBox
extends Area2D

@export var damage : float = 10.0

func _init() -> void:
	collision_layer = 2
	collision_mask = 0
