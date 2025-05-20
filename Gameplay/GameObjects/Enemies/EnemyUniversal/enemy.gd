extends CharacterBody2D

@onready var anim_tree : AnimationTree = $AnimationTree
@onready var anim_player : AnimationPlayer = $AnimationPlayer

var dir_to_player : Vector2 = Vector2(0.0,0.0)

@export var move_speed : float = 50.0 # 3 times less then player
@export var exp_spawn_range : float = 20.0
@export var contact_damage_to_player : float = 10.0

# For object pooling
func _ready() -> void:
	self.set_physics_process(false)
	self.visible = false
	self.position = Vector2(-2000.0,-2000.0)
	
func reset() -> void:
	self.hide_on_minimap()
	self.set_physics_process(false)
	self.visible = false
	self.position = Vector2(-2000.0,-2000.0)

func update_animation_parametrs() -> void:
	anim_tree["parameters/blend_position"] = dir_to_player.x

func _physics_process(_delta: float) -> void:
	dir_to_player = position.direction_to(SceneControl.player_link.position)
	update_animation_parametrs()
	if knockback_state:
		var opposite_dir = dir_to_player.rotated(PI)
		velocity = opposite_dir * knockback_speed
		move_and_slide()		
	else:
		velocity = dir_to_player * move_speed
		move_and_slide()
	move_on_minimap()
	
func get_contact_damage() -> float:
	return contact_damage_to_player

#region Taking damage and knockback

@onready var health_bar : ProgressBar = $ProgressBar_HP
@onready var timer_knockback : Timer = $Timer_Knockback
@onready var damage_anim : AnimationPlayer = $AnimationPlayer_TakeDamage

var monster_health : float = 100.0 : set = _set_monster_health
var knockback_state : bool = false
var knockback_speed :float = 0.0

func _set_monster_health(new_h : float) -> void:
	monster_health = new_h
	health_bar.value = new_h

func get_hit(dmg : float, knockback_t : float, knockback_s : float) -> void:
	monster_health = monster_health - dmg
	if monster_health < 0:
		# Death animation??
		spawn_expirience()
		SceneControl.game_session.enemies_pool.kill_enemy(self)
		# object pool !!!
		return
		#minimap_node_link.queue_free()
		#queue_free()
	knockback_state = true
	knockback_speed = knockback_s
	damage_anim.play("take_damage")
	timer_knockback.start(knockback_t)
	
func _on_timer_knockback_timeout() -> void:
	knockback_state = false
	
func spawn_expirience() -> void:
	var rnd_point = (Vector2.RIGHT * randf_range(0, exp_spawn_range)).rotated(randf_range(0, 2*PI))
	var new_powerup_dat = PowerupSave.new()
	new_powerup_dat.type = PowerupSave.PowerupType.EXPIRIENCE
	new_powerup_dat.pos = rnd_point + global_position
	SceneControl.game_session.powerup_pool.activate_powerup(new_powerup_dat) 	
		
#endregion

#region Minimap
# Картинка корабля игрока для миникарты 
var minimap_picture : CompressedTexture2D = load("res://Gameplay/GameObjects/Enemies/EnemyUniversal/bug_minimap_icon.png")
var minimap_link : Control = null
# Ссылка на корабль на миникарте, чтобы знать что двигать
var minimap_node_link : Node2D = null

func init_on_minimap(map_link : Control) -> void:
	minimap_link = map_link
	minimap_node_link = minimap_link.add_sprite(minimap_picture,self.position,0.0)
	minimap_node_link.scale.x = minimap_node_link.scale.x * 2.3#0.7
	minimap_node_link.scale.y = minimap_node_link.scale.y * 2.3#0.7
	
func move_on_minimap() -> void:
	minimap_link.move_sprite(minimap_node_link,self.position,0.0)	
	
func show_on_minimap() -> void:
	minimap_node_link.visible = true
	
func hide_on_minimap() -> void:
	minimap_node_link.visible = false
#endregion

#region Save Load
# Попробую сохранять и восстанавливать состояние

# Gets all needed info from game session
# Called on object loading, linking to game session objects
func init_get_info(game_session : Node2D) -> void:
	init_on_minimap(game_session.minimap)

func on_save_game(saved_data : Array[BaseSaveObject]) -> void:
	var my_data = EnemyBugSave.new()
	my_data.pos = global_position
	#my_data.scene_path = scene_file_path
	my_data.health = monster_health	
	
	saved_data.append(my_data)
	
func init(saved_data : BaseSaveObject) -> void:
	var my_data : EnemyBugSave = saved_data as EnemyBugSave
	global_position = my_data.pos
	monster_health = my_data.health
	
func on_load_game_linking() -> void:
	return
	#target_hive = SaveBaseInfo.find_linkable(hive_link_number_to)	
	
func set_rot(_new_rot : float) -> void:
	return
	#myMovementData.current_rotation = new_rot
	#rotation_node.rotation_degrees = new_rot
#endregion
