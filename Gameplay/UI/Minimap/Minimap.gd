extends Control
# !!!! Пусть UI миникарты всегда квадрат, для удобства рассчетов и отображения аспекта игрового поля

@onready var camera_minimap_frame : Polygon2D = $ColorRect_BlackBack/ColorRect_Minimap/Polygon2D_CameraFrame
@onready var back_rect : ColorRect = $ColorRect_BlackBack
@onready var minimap_parallelogram : ColorRect = $ColorRect_BlackBack/ColorRect_Minimap
@onready var position_timeout : Timer = $Timer

var camera_node = null

var game_field_size : Vector2 = Vector2(0.0,0.0)

var transform_scale : float = 0.0
var transform_scale_inverse : float = 0.0

#Для доступа извне
var minimap_size : Vector2 = Vector2(0.0,0.0)
var minimap_offset : Vector2 = Vector2(0.0,0.0)

#region Для объектов со спрайтами

# Добавляем спрайт для объекта и возвращаем ссылку,
#	ссылку сохранит сам объект и будет для него вызывать функцию
#	движения миникарты (ссылка на миникарту у объекта тоже будет)
#		а зачем везде ссылки на миникарту? Чтобы без глобального модуля
func add_sprite(sprite_texture : Texture2D, init_pos : Vector2, init_rot : float) -> Node2D:
	var new_sprite = Sprite2D.new()
	new_sprite.texture = sprite_texture
	new_sprite.centered = true
	self.add_child(new_sprite)
	move_sprite(new_sprite,init_pos,init_rot)
	return new_sprite

func move_sprite(spr : Node2D, new_pos : Vector2, new_rot : float) -> void:
	spr.position = new_pos * transform_scale + minimap_offset
	spr.rotation_degrees = new_rot
#endregion

func add_polygon(polyg:Node) -> void:
	minimap_parallelogram.add_child(polyg)	

# !! Это нужно для движения камеры при помощи миникарты.
func _set_camera_coords_from_minimap(local_pos : Vector2) -> void:
	#camera.position.x = local_pos.x/minimap_sides2.x * game_field_size.x
	#camera.position.y = local_pos.y/minimap_sides2.y * game_field_size.y
	
	# Просто прибавить оффсет (вычесть)
	camera_minimap_frame.position = local_pos - minimap_offset
	
	# Теперь надо передать движение на камеру
	camera_node.position = camera_minimap_frame.position * transform_scale_inverse
	#Logging.logg("camera_node.position: "+str(camera_node.position),Logging.MessageType.DEBUG)

#func _process(delta):
#	var a = minimap_parallelogram.position
	#Logging.logg("Minimap coords: "+str(a),Logging.MessageType.DEBUG)

#region Движение рамки камеры по миникарте
# функции вызываются из модуля камеры
var base_camera_frame = Vector3(0.0,0.0,0.0) # Задается в my_init

func move_camera(camera_pos : Vector2):
	camera_minimap_frame.position = camera_pos*transform_scale
	#await (position_timeout.start(0.5)) Почему не работает??
	#await get_tree().create_timer(0.5).timeout

func zoom_camera(c_zoom : Vector2) -> void:
	var new_frame_x : float = base_camera_frame.x*(1.0/c_zoom.x)
	var new_frame_y : float = base_camera_frame.y*(1.0/c_zoom.y)
	set_rectangular_frame(camera_minimap_frame,
		new_frame_x,
		new_frame_y,
		base_camera_frame.z)
	# Наоборот потому что в set_rectangular_frame перепутано
	camera_minimap_frame.offset = -Vector2(new_frame_y,new_frame_x)/2.0
#endregion

# Не в ready потому что сначала должен быть задан размер игрового поля
func my_init(c_zoom : Vector2 = Vector2(1.0,1.0), pre_game_showcase : bool = false):
	
	#if !pre_game_showcase: # Вне игры камера не нужна
		# Сигнал движения от камеры, приходится так а не трансформом
	#	camera_node.camera_position_changed.connect(translate_camera_movement,1)
	
	# Здесь мне надо посчитать необходимые для работы миникарты данные, как scale трансформа
	# Так же местоположение для поля карты (из-за аспекта)
		# Раньше был viewport на все игровое поле, теперь одна маленькая картинка.
		#	Надеюсь это повысит производительность.
	var game_field_aspect : float = game_field_size.x/game_field_size.y
	
	if game_field_aspect < 1: 	# По Y длинее чем по X
		minimap_parallelogram.size.y = back_rect.size.y # По Y полное растягивание
		minimap_parallelogram.position.y = 0.0
		
		minimap_parallelogram.size.x = back_rect.size.x * game_field_aspect 
		# Недостача до квадрата по X. UI миникарты всегда должен быть квадратом,
		#	так что из-за аспекта игрового поля будет черное пространство в UI
		var x_aspect_lack : float = 1.0 - game_field_aspect
		# По X отступ на половину недостачи
		minimap_parallelogram.position.x = back_rect.size.x*x_aspect_lack/2.0	
	else: 						# По X длинее чем по Y
		game_field_aspect = 1/game_field_aspect # перевернем для удобства
		minimap_parallelogram.size.x = back_rect.size.x # По X полное растягивание
		minimap_parallelogram.position.x = 0.0
		
		minimap_parallelogram.size.y = back_rect.size.y * game_field_aspect
		var y_aspect_lack : float = 1.0 - game_field_aspect
		# По Y отступ на половину недостачи
		minimap_parallelogram.position.y = back_rect.size.y*y_aspect_lack/2.0
 
	# Не важно по X или по Y брать, аспект один и тот же
	transform_scale = minimap_parallelogram.size.x/game_field_size.x
	transform_scale_inverse = 1.0/transform_scale
	
	minimap_offset = minimap_parallelogram.position
	minimap_size = minimap_parallelogram.size + minimap_parallelogram.position
	

	if !pre_game_showcase: # Вне игры камера не нужна
		var screen_size : Vector2 = DisplayServer.window_get_size()
		
		base_camera_frame = Vector3(screen_size.y*transform_scale,screen_size.x*transform_scale,6)#200*transform_scale)
		
		var camera_minimap_frame_height : float = base_camera_frame.x*(1.0/c_zoom.x)
		var camera_minimap_frame_width : float = base_camera_frame.y*(1.0/c_zoom.y)
		
		# Размер квадрата камеры
		set_rectangular_frame(camera_minimap_frame, 
			base_camera_frame.x,
			base_camera_frame.y,
			base_camera_frame.z)
		camera_minimap_frame.offset = -Vector2(camera_minimap_frame_width,camera_minimap_frame_height)/2.0
		#camera_minimap_frame.offset = #-screen_size*transform_scale#-screen_size/2.0*transform_scale
		#camera_minimap_frame.offset = Vector2(-base_camera_frame.y*(1.0/c_zoom.y)/2.0,-base_camera_frame.x*(1.0/c_zoom.x)/2.0)

func set_rectangular_frame(poly: Polygon2D, height: float, width: float, thickness: float):
	var half_thickness = thickness/2.0
	#var offset_height = height/2.0
	#var offset_width = width/4.0
	#var outer_top_left = Vector2(0 - offset_width, 0 + offset_height)
	#var outer_top_right = Vector2(width - offset_width, 0 + offset_height)
	#var outer_bottom_right = Vector2(width - offset_width, height + offset_height)
	#var outer_bottom_left = Vector2(0 - offset_width, height + offset_height)
	#var inner_top_left = Vector2(half_thickness - offset_width, half_thickness + offset_height)
	#var inner_top_right = Vector2(width  - offset_width- half_thickness, half_thickness + offset_height)
	#var inner_bottom_right = Vector2(width  - offset_width- half_thickness, height - half_thickness + offset_height)
	#var inner_bottom_left = Vector2(half_thickness - offset_width, height - half_thickness + offset_height)
	var outer_top_left = Vector2(0, 0)
	var outer_top_right = Vector2(width, 0)
	var outer_bottom_right = Vector2(width, height)
	var outer_bottom_left = Vector2(0, height)
	var inner_top_left = Vector2(half_thickness, half_thickness)
	var inner_top_right = Vector2(width - half_thickness, half_thickness)
	var inner_bottom_right = Vector2(width - half_thickness, height - half_thickness)
	var inner_bottom_left = Vector2(half_thickness, height - half_thickness)
	var points = [
		outer_top_left,
		outer_top_right,
		inner_top_right,
		inner_top_left,
		inner_bottom_left,
		inner_bottom_right,
		inner_top_right,
		outer_top_right,
		outer_bottom_right,
		outer_bottom_left
	]
	#PackedVector2Array
	poly.polygon = points	
