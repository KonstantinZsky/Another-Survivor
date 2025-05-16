extends Node2D

@onready var anim_p : AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	anim_p.play("wave")
	
