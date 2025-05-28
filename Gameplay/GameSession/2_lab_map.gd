extends Control

@onready var tile_layer : TileMapLayer = $Layer0

func get_layer_link() -> TileMapLayer:
	return tile_layer
