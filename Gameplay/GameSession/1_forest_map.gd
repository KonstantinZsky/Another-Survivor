extends Control


func _on_area_2d_walls_body_entered(_body: Node2D) -> void:
	pass # Replace with function body.

@onready var tile_layer : TileMapLayer = $Layer0

func get_layer_link() -> TileMapLayer:
	return tile_layer
