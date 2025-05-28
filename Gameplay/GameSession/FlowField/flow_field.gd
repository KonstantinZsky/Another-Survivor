class_name FlowFieldManager
extends Node

var flow_field : PackedVector2Array = PackedVector2Array()
var costs: PackedInt32Array = PackedInt32Array()

@export var field_size : Vector2 = Vector2(60,60)
#@onready var bounds := Rect2i(Vector2i.ZERO - Vector2i(field_size)/2, field_size)
@onready var bounds := Rect2i(Vector2i.ZERO, field_size)

@export var tile_map: TileMapLayer
@export var flow_field_tilemap: TileMapLayer

const TILE_SIZE: int = 16
const MAX_COST: int = 999999

@export var target: Node2D
@export var show_debug_arrows: bool = false:
	set(val):
		show_debug_arrows = val
		if not flow_field_tilemap:
			return
		flow_field_tilemap.visible = show_debug_arrows
var target_tile: Vector2i = Vector2i.ZERO

var cost_queue: Array[Vector2i] = []

const DIRECTIONS = [
	Vector2.UP,
	Vector2(1,-1),
	Vector2.RIGHT,
	Vector2.ONE,
	Vector2.DOWN,
	Vector2(-1,1),
	Vector2.LEFT,
	Vector2(-1,-1),
	Vector2.ZERO
]

@onready var timer : Timer = $Timer

func _ready() -> void:
	initialize_field()
	timer.start()
	
func initialize_field() -> void:
	for x in field_size.x:
		for y in field_size.y:
			costs.append(MAX_COST)
			flow_field.append(Vector2.ZERO)

func get_field_index(cell: Vector2i) -> int:
	var offset := cell - bounds.position
	var index: int = offset.y * bounds.size.x + offset.x
	return clampi(index, 0, flow_field.size() - 1)

func index_to_cell(index: int) -> Vector2i:
	var x = index % bounds.size.x
	var y = index / bounds.size.x
	return Vector2i(x,y) + bounds.position

func add_cost_to_cell(pos: Vector2i) -> void:
	var index: int = get_field_index(Vector2i(pos/TILE_SIZE))
	costs[index] += 1

func get_field_direction(pos: Vector2) -> Vector2:
	var index: int = get_field_index(Vector2i(pos/TILE_SIZE))
	if index < 0 or index >= flow_field.size():
		# log error "cant find flow field direction" 
		return Vector2.ZERO
	return flow_field[index].normalized()

func get_neighbour_cells(current_cell) -> Array[Vector2i]:
	return[
		current_cell + Vector2i.UP,
		current_cell + Vector2i.RIGHT,
		current_cell + Vector2i.DOWN,
		current_cell + Vector2i.LEFT,
		current_cell + Vector2i(-1,-1),
		current_cell + Vector2i(1,-1),
		current_cell + Vector2i(1,1),
		current_cell + Vector2i(-1,1)
	]

@export var enemies_pool : Node2D
var enemies_indexes : Array[int] = []

#func _physics_process(delta: float) -> void:
	#enemies_indexes = []
	##update costs with enemies 
	#var enemies : Array = enemies_pool.get_active_enemies()
	#for enemy in enemies:
		#var index: int = get_field_index(Vector2i(enemy.global_position/TILE_SIZE))
		#if index < 0 or index >= flow_field.size():
			#enemy.have_flow_field_direction = false
			#continue
		#enemy.flow_field_dir = flow_field[index].normalized()
		#enemy.have_flow_field_direction = true
		#enemies_indexes.push_back(index)	
	#generate_flow_field()

func _on_timer_timeout() -> void:
	enemies_indexes = []
	#update costs with enemies 
	var enemies : Array = enemies_pool.get_active_enemies()
	for enemy in enemies:
		var index: int = get_field_index(Vector2i((enemy.global_position/TILE_SIZE).floor()))
		if index < 0 or index >= flow_field.size():
			enemy.have_flow_field_direction = false
			continue
		enemy.flow_field_dir = flow_field[index].normalized()
		enemy.have_flow_field_direction = true
		enemies_indexes.push_back(index)	
	generate_flow_field()

var my_ready : bool = false

func generate_flow_field(force: bool = false) -> void:
	if !my_ready:
		return
	
	var next_target_tile: Vector2i = Vector2i((target.global_position / TILE_SIZE).floor())
	
	target_tile = next_target_tile
	bounds.position = target_tile - Vector2i(field_size) / 2
	costs[get_field_index(target_tile)] = 0
	
	cost_queue = [target_tile]
	var seen: Dictionary = {}

	while not cost_queue.is_empty():
		var current_cell = cost_queue.pop_front()
		seen[current_cell] = true
		
		var index: int = get_field_index(current_cell)
		if costs[index] == MAX_COST:
			continue
		
		for neighbor_cell in get_neighbour_cells(current_cell):
			var cell_rect: Rect2i = Rect2i(neighbor_cell.x, neighbor_cell.y,1,1)
			if seen.has(neighbor_cell) or not bounds.encloses(cell_rect):
				continue
			var neighbor_cell_index: int = get_field_index(neighbor_cell)
			var tile_data: TileData = tile_map.get_cell_tile_data(neighbor_cell)
			var travel_cost: int = tile_data.get_custom_data("travel_cost")
			
			if tile_data and tile_data.get_collision_polygons_count(0) > 0:
				costs[neighbor_cell_index] = MAX_COST
			elif enemies_indexes.has(neighbor_cell_index):
				costs[neighbor_cell_index] = MAX_COST
				cost_queue.append(neighbor_cell)
			else:
				costs[neighbor_cell_index] = costs[index] + travel_cost
				cost_queue.append(neighbor_cell)
			
			seen[neighbor_cell] = true
			
			var angle = Vector2(target_tile).angle_to_point(Vector2(neighbor_cell))
			if abs(angle - snappedf(angle, PI / 2)) > PI / 12:
				costs[neighbor_cell_index] += 1
					
	for i in flow_field.size():
		var cell: Vector2i = index_to_cell(i)
		if cell == target_tile:
			continue
			
		var cheapest: int = MAX_COST
		var cheapest_neighbor = cell
		for neighbor_cell in get_neighbour_cells(cell):
			var neighbor_index: int = get_field_index(neighbor_cell)
			
			var cell_rect: Rect2i = Rect2i(neighbor_cell.x,neighbor_cell.y,1,1)
			if not bounds.encloses(cell_rect):
				continue
			
			var cost: int = costs[neighbor_index]
			if cost < cheapest:
				cheapest = cost
				cheapest_neighbor = neighbor_cell
		flow_field[i] = Vector2(cheapest_neighbor - cell)
		var atlas_coord : Vector2i = Vector2i(DIRECTIONS.find(flow_field[i]),0)
		#atlas_coord = Vector2i(0,0)
		flow_field_tilemap.set_cell(cell,11, atlas_coord)
