extends CharacterBody2D

@onready var anim_tree : AnimationTree = $AnimationTree
@onready var anim_player : AnimationPlayer = $AnimationPlayer

var dir_to_player : Vector2 = Vector2(0.0,0.0)

@export var move_speed : float = 150.0 

# Not used yet, only 1 powerup type
var powerup_type = PowerupSave.PowerupType.EXPIRIENCE

# Powerup absorbed by player, free object
func absorbed() -> void:
	SceneControl.game_session.powerup_pool.kill_powerup(self)

# For object pooling
func _ready() -> void:
	self.set_physics_process(false)
	self.visible = false
	self.position = Vector2(-2000.0,-2000.0)
	anim_tree["parameters/blend_position"] = 0.0
	
func reset() -> void:
	self.hide_on_minimap()
	self.set_physics_process(false)
	self.visible = false
	self.position = Vector2(-2000.0,-2000.0)
	powerup_gathered = false

func update_animation_parametrs() -> void:
	anim_tree["parameters/blend_position"] = dir_to_player.x

var powerup_gathered = false

func _physics_process(_delta: float) -> void:
	if powerup_gathered:
		dir_to_player = position.direction_to(SceneControl.player_link.position)
		update_animation_parametrs()

		velocity = dir_to_player * move_speed
		move_and_slide()
		move_on_minimap()

#region Minimap
# Картинка корабля игрока для миникарты 
var minimap_picture : CompressedTexture2D = load("res://Gameplay/GameObjects/Powerups/Expirience/expirience_icon.png")
var minimap_link : Control = null
var minimap_node_link : Node2D = null

func init_on_minimap(map_link : Control) -> void:
	minimap_link = map_link
	minimap_node_link = minimap_link.add_sprite(minimap_picture,self.position,0.0)
	minimap_node_link.scale.x = minimap_node_link.scale.x * 1.0#0.7
	minimap_node_link.scale.y = minimap_node_link.scale.y * 1.0#0.7
	
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
	var my_data = PowerupSave.new()
	my_data.pos = global_position
	my_data.type = powerup_type
		
	saved_data.append(my_data)
	
func init(saved_data : BaseSaveObject) -> void:
	var my_data : PowerupSave = saved_data as PowerupSave
	global_position = my_data.pos
	powerup_type = my_data.type
	
func on_load_game_linking() -> void:
	return
	#target_hive = SaveBaseInfo.find_linkable(hive_link_number_to)	
	
func set_rot(_new_rot : float) -> void:
	return
	#myMovementData.current_rotation = new_rot
	#rotation_node.rotation_degrees = new_rot
#endregion
