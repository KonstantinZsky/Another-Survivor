extends Camera2D

var move_speed : float = 500.0

# Free camera during pause
var free_camera : bool = false
@onready var player_transform : RemoteTransform2D = $"../Node2D_Player/RemoteTransform2D_Camera"
@onready var game_paused_label : Label = $"../CanvasLayer/Label_GamePaused"
@onready var game_session : Node2D = $".."

var camera_limits = Vector2.ZERO

#region Minimap

var minimap_link : Control = null

func init_on_minimap(map_link : Control) -> void:
	minimap_link = map_link
	minimap_link.move_camera(position)
	minimap_link.zoom_camera(zoom)

func set_camera_position(new_pos):
	position = new_pos 
	minimap_link.move_camera(position)
	
#endregion

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Pause_game_session") && !game_session.menu_paused:
		toggle_pause()
	if Input.is_action_just_pressed("ui_cancel") && free_camera:
		toggle_pause()
	
	if !free_camera:
		return

	var velocity_dir : Vector2 = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	
	var velocity : Vector2 = Vector2(0.0,0.0)
	
	if velocity_dir:
		velocity = velocity_dir * move_speed
		
	position = position + velocity*delta
	
	position.x = clamp(position.x,0,camera_limits.x)
	position.y = clamp(position.y,0,camera_limits.y)		
	

func toggle_pause() -> void:
	free_camera = !get_tree().paused
	get_tree().paused = free_camera
	game_paused_label.visible = free_camera
	player_transform.update_position = !free_camera

func _physics_process(_delta: float) -> void:
	minimap_link.move_camera(position)
