extends CharacterBody2D

@export var move_speed : float = 150.0

@onready var anim_tree : AnimationTree = $AnimationTree

@onready var bat_swing : Node2D = $Node2D_BatSwing
@onready var bat_swing_sprite : AnimatedSprite2D = $Node2D_BatSwing/AnimatedSprite2D

#var inited : bool = false

func update_animation_parametrs(velocity_dir : Vector2) -> void:
	if velocity_dir == Vector2(0.0,0.0):
		anim_tree["parameters/conditions/idle"] = true
		anim_tree["parameters/conditions/move"] = false
	else:
		anim_tree["parameters/conditions/idle"] = false
		anim_tree["parameters/conditions/move"] = true
		if velocity_dir.x != 0:
			anim_tree["parameters/Idle/blend_position"] = velocity_dir.x
			anim_tree["parameters/Move/blend_position"] = velocity_dir.x

# Для восстановления ссылок при загрузке
# Для корабля игрока всегда 1, не надо сохранять и загружать
var link_number_self : int = 1

func _ready() -> void:
	anim_tree.active = true
	bat_swing_sprite.play("swing")

func init(game_session : Node2D) -> void:
	init_on_minimap(game_session.minimap)
	init_exp_weapon_system(game_session)

func _physics_process(_delta: float) -> void:

	var velocity_dir : Vector2 = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	
	if velocity_dir:
		velocity = velocity_dir * move_speed
	else:
		velocity = Vector2.ZERO
	
	update_animation_parametrs(velocity_dir)	
	move_and_slide()
	move_on_minimap()
	
	# Turn attack animation to mouse
	var current_mouse_position = get_global_mouse_position()	
	var controlled_object_pos_on_screen = position
	var vector_to_mouse = current_mouse_position-controlled_object_pos_on_screen
	var degrees_to_mouse = _myCalculateAngle(vector_to_mouse.y,vector_to_mouse.x)*180.0/PI-45/PI
	if 	degrees_to_mouse > 180.0 :
		bat_swing.scale.x = -1.0
		bat_swing.rotation_degrees = degrees_to_mouse - 180.0
	else:
		bat_swing.scale.x = 1.0
		bat_swing.rotation_degrees = degrees_to_mouse		

	
	## Подгоняем камеру. Вопрос - а что с движением самой камеры от кнопок?
	#if !ignore_input:
		#camera_link.set_camera_position(player_ship_node.position)
	#
	##Миникарта
	#player_ship_node.move_on_minimap()		
	
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

#region Миникарта, отображение
# Картинка корабля игрока для миникарты 
var minimap_picture : CompressedTexture2D = load("res://Gameplay/GameObjects/Player/player_minimap_icon.png")
var minimap_link : Control = null
# Ссылка на корабль на миникарте, чтобы знать что двигать
var minimap_node_link : Node2D = null

func init_on_minimap(map_link : Control) -> void:
	minimap_link = map_link
	minimap_node_link = minimap_link.add_sprite(minimap_picture,self.position,0.0)
	minimap_node_link.scale.x = minimap_node_link.scale.x * 3.0#0.7
	minimap_node_link.scale.y = minimap_node_link.scale.y * 3.0#0.7
	
func move_on_minimap() -> void:
	minimap_link.move_sprite(minimap_node_link,self.position,0.0)	
#endregion

#region Player takes damage

# Player can take damage only once couple of seconds
@onready var contact_damage_timer : Timer = $Timer_ContactDamage

@onready var damage_anim : AnimationPlayer = $AnimationPlayer_TakeDamage

var player_health : float = 100.0 : set = _set_player_health

@onready var health_bar : ProgressBar = $ProgressBar_HP
func _set_player_health(new_h : float) -> void:
	player_health = new_h
	health_bar.value = new_h
	if player_health < 0.0:
		SceneControl.current_scene_state = SceneControl.MySceneState.GAME_LOST

func take_contact_damage() -> void:
	if contact_damage_timer.is_stopped():
		calc_and_take_contact_damage()
		contact_damage_timer.start()

func _on_timer_contact_damage_timeout() -> void:
	var dmg = check_contact()
	if dmg > 0:
		damage_anim.play("take_damage")
		player_health = player_health - dmg	
	else:
		contact_damage_timer.stop()

func calc_and_take_contact_damage() -> void:
	var dmg = check_contact()
	if dmg > 0:
		damage_anim.play("take_damage")
		player_health = player_health - dmg	

func check_contact() -> float:
	var arr : Array = enemies_in_hurt_box.keys()
	return arr.max()

# Enemies in players hurt box
# Key is enemy damage, value is enemy quantity in hurt box
# If quantity goes to 0 field is deleted
#  0 0 always exist for the case of no enemies
var enemies_in_hurt_box : Dictionary = {
	0 : 0
}

func _on_area_2d_hurt_box_body_entered(body: Node2D) -> void:
	var contact_damage = body.get_contact_damage()
	if enemies_in_hurt_box.has(contact_damage):
		enemies_in_hurt_box[contact_damage] = enemies_in_hurt_box[contact_damage] + 1
	else:
		enemies_in_hurt_box[contact_damage] = 1
	take_contact_damage()

func _on_area_2d_hurt_box_body_exited(body: Node2D) -> void:
	var contact_damage = body.get_contact_damage()
	enemies_in_hurt_box[contact_damage] = enemies_in_hurt_box[contact_damage] - 1
	if enemies_in_hurt_box[contact_damage] == 0:
		enemies_in_hurt_box.erase(contact_damage)
		
#endregion

#region Damaging monsters

func _on_area_2d_hit_box_body_entered(body: Node2D) -> void:
	body.get_hit(40.0 # Damage
	,0.2 # Konckback time
	,100.0) # Knockback speed, double bug speed
	
@onready var bat_sprite : AnimatedSprite2D = $Node2D_BatSwing/AnimatedSprite2D
@onready var bat_hit_box : Area2D = $Node2D_BatSwing/Area2D_HitBox
	
func _on_animated_sprite_2d_frame_changed() -> void:
	if bat_sprite.frame == 1:
		bat_hit_box.monitoring = true
	else:
		bat_hit_box.monitoring = false
		
#endregion

#region Gathering powerups

@onready var exp_weapon_system : Node2D = $Node2D_ExpWeaponSystem

func  init_exp_weapon_system(game_session : Node2D) -> void:
	exp_weapon_system.exp_bar_link = game_session.exp_bar_node

func _on_area_2d_gather_powerups_body_entered(body: Node2D) -> void:
	body.powerup_gathered = true
	
func _on_area_2d_absorb_powerups_body_entered(body: Node2D) -> void:
	exp_weapon_system.gain_powerup(body)
	body.absorbed()
	
#endregion
