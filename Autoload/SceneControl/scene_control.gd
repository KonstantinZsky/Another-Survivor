extends Control

@export var main_menu_scene : PackedScene
#@export var _game_session_scene : PackedScene

@onready var scene_canvas : CanvasLayer = $CanvasLayer
@onready var progress_bar : ProgressBar = $CanvasLayer/ProgressBar
@onready var timer_emulate_long_load : Timer = $Timer

# So that monsters could see where the player is
var player_link : CharacterBody2D = null

var game_session_scene_path : String = "res://Gameplay/GameSession/GameSession.tscn"

var loading_started : bool = false

var save_menu_opened : bool = false

var progress : Array = []

var lvl1_game_field_size : Vector2 = Vector2(460.0,460.0)
var lvl2_game_field_size : Vector2 = Vector2(800.0,600.0)

@export var _it_is_load = false
var game_session_active : bool = false

func _process(_delta: float) -> void:
	if !loading_started:
		return
	ResourceLoader.load_threaded_get_status(game_session_scene_path,progress)
	#progress_bar.value = progress[0]*100.0
	progress_bar.value = progress[0]*90.0
	if progress[0] == 1:
		progress_bar.value = progress[0]*90.0 + (3.0-timer_emulate_long_load.time_left)/3.0*10.0	
		if timer_emulate_long_load.is_stopped():
			var packed_scene = ResourceLoader.load_threaded_get(game_session_scene_path)
			get_tree().paused = false
			get_tree().change_scene_to_packed(packed_scene)
			scene_canvas.visible = false
			loading_started = false
			game_session_active = true

func load_game_session() -> void:
	#get_tree().change_scene_to_packed(_game_session_scene)
	ResourceLoader.load_threaded_request(game_session_scene_path)
	progress_bar.value = 0
	loading_started = true
	timer_emulate_long_load.start()
	scene_canvas.visible = true
	get_tree().paused = true

# Doesnt work
func load_main_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_packed(main_menu_scene)
	game_session_active = false
