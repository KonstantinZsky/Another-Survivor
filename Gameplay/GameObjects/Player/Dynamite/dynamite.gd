extends Node2D

@export var my_scale : float = 1.0

@export var damage : float = 40.0

@onready var explosion_size : Area2D = $Area2D_HitBox
@onready var dynamite_sprite : AnimatedSprite2D = $AnimatedSprite2D_Dynamite
@onready var explosion_sprite : AnimatedSprite2D = $Area2D_HitBox/AnimatedSprite2D_Explosion

func _ready() -> void:
	explosion_size.scale = Vector2(my_scale,my_scale)
	dynamite_sprite.play("default") 
	
# explodes after 2 s
func _on_timer_timeout() -> void:
	dynamite_sprite.visible = false
	explosion_sprite.visible = true
	explosion_sprite.play("default") 

func _on_area_2d_hit_box_body_entered(body: Node2D) -> void:
	body.get_hit(damage # 40.0 # Damage
	,0.2 # Konckback time
	,100.0) # Knockback speed, double bug speed
	#self.queue_free()

func _on_animated_sprite_2d_explosion_frame_changed() -> void:
	#if explosion_sprite.frame >= 1 && explosion_sprite.frame <= 3:
	if explosion_sprite.frame == 1:
		explosion_size.monitoring = true
	else:
		explosion_size.monitoring = false
	
	if explosion_sprite.frame == 7:
		self.queue_free()
