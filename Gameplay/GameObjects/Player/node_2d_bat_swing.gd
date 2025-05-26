extends Node2D

@onready var bat_swing_sprite : AnimatedSprite2D = $AnimatedSprite2D

var cur_damage  : float = 40.0
var cur_scale : float = 1.0

@export var stats : WeaponStatsClass

# Bat swing always active, its base weapon
func _ready() -> void:
	bat_swing_sprite.play("swing")

func _physics_process(_delta: float) -> void:

	# Turn attack animation to mouse
	var current_mouse_position = get_global_mouse_position()	
	var controlled_object_pos_on_screen = global_position
	var vector_to_mouse = current_mouse_position-controlled_object_pos_on_screen
	var degrees_to_mouse = _myCalculateAngle(vector_to_mouse.y,vector_to_mouse.x)*180.0/PI-45/PI
	if 	degrees_to_mouse > 180.0 :
		self.scale.x = -cur_scale #-1.0 
		self.rotation_degrees = degrees_to_mouse - 180.0
	else:
		self.scale.x = cur_scale # 1.0
		self.rotation_degrees = degrees_to_mouse		
	
# Почему-то atan2 возвращает угол: 0 270 -90,
#	сделал свой расчет угла: 0 360
static func _myCalculateAngle(y : float, x : float) -> float:
	var angle : float = 0.0
	if x == 0.0:
		angle = -PI/2.0
		#if y == 0.0:
		#	angle = 0.0
		#elif y > 0.0:
		#	angle = PI/2.0
		#else:
		#	angle = PI/2.0
	else:
		angle = atan(y/x)
		if x < 0.0:
			if y > 0.0:
				angle += PI
			elif y < 0.0:
				# angle -= PI
				angle += PI
			else:
				angle = PI
	return angle

#region Damaging monsters

func set_new_level( n_l : int ) -> void:
	stats.current_level = n_l
	update_weapon_stats()

func update_weapon_stats() -> void:
	bat_swing_sprite.speed_scale = stats.get_speed()
	var scale = stats.get_scale()
	self.scale.x = scale
	self.scale.y = scale
	cur_damage = stats.get_damage()

func _on_area_2d_hit_box_body_entered(body: Node2D) -> void:
	body.get_hit(cur_damage # 40.0 # Damage
	,0.2 # Konckback time
	,100.0) # Knockback speed, double bug speed
	
@onready var bat_hit_box : Area2D = $Area2D_HitBox
	
func _on_animated_sprite_2d_frame_changed() -> void:
	if bat_swing_sprite.frame == 1:
		bat_hit_box.monitoring = true
	else:
		bat_hit_box.monitoring = false
		
#endregion
