extends Node2D

@export var speed_base : float = 300.0
@export var speed : float = 300.0

@export var direction : Vector2 = Vector2(0.0,0.0)

var velocity : Vector2

@export var my_scale : float = 1.0

@export var damage : float = 40.0

@onready var ball_size : Area2D = $Area2D_HitBox

func _ready() -> void:
	velocity = direction * speed
	ball_size.scale = Vector2(my_scale,my_scale)
	
func _physics_process(delta: float) -> void:
	position = position + delta * velocity

# lives 0.5 seconds
func _on_timer_timeout() -> void:
	self.queue_free()

func _on_area_2d_hit_box_body_entered(body: Node2D) -> void:
	body.get_hit(damage # 40.0 # Damage
	,0.2 # Konckback time
	,100.0) # Knockback speed, double bug speed
	self.queue_free()
