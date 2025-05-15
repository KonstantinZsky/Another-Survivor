extends Node2D

@export var enemy_bug_scene : PackedScene

@onready var enemies_node : Node2D = $"../../Node2D_Enemies"

@onready var map_link : Control = $"../../CanvasLayer/Minimap"

@onready var spawn_path : PathFollow2D = $Path2D_SpawnLine/PathFollow2D
@onready var spawn_point : Node2D = $Path2D_SpawnLine/PathFollow2D/Node2D_PathPosition
var spawn_move_speed : float = 0.33 # 1.0 is full circle
var spawn_pos : float = 0.0 # <= 1.0
var enemies_to_spawn : int = 0

# Checking collision befor spawn
var p_check : PhysicsPointQueryParameters2D = null
var space_state : PhysicsDirectSpaceState2D = null

func _ready() -> void:
	p_check = PhysicsPointQueryParameters2D.new()
	p_check.collide_with_areas = true 
	space_state = get_world_2d().direct_space_state
	
func _on_timer_spawn_add_count_timeout() -> void:
	enemies_to_spawn = enemies_to_spawn + 1

func _on_timer_spawn_attempt_timeout() -> void:
	spawn_pos = spawn_pos + 0.1 # To randomise positions
	if spawn_pos > 1.0:
		spawn_pos = spawn_pos - 1.0	
	if get_world_2d().direct_space_state.intersect_point(p_check, 1):
		return
		
	var new_bug : CharacterBody2D = enemy_bug_scene.instantiate()
	new_bug.add_to_group("to_save")
	new_bug.position = p_check.position
	new_bug.init_on_minimap(map_link) 
	enemies_node.add_child(new_bug)	
	
func _on_timer_spawn_rotate_timeout() -> void:
	spawn_pos = spawn_pos + spawn_move_speed
	if spawn_pos > 1.0:
		spawn_pos = spawn_pos - 1.0
	spawn_path.progress_ratio = spawn_pos
	var g_pos : Vector2 = spawn_point.global_position
	p_check.position = g_pos
	
