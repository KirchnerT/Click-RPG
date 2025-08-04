class_name TileMapManager
extends Node2D

@onready var terrain_layer: TileMapLayer = $TerrainLayer
@onready var prop_layer: TileMapLayer = $PropLayer
@onready var highlight_layer: TileMapLayer = $HighlightLayer

enum Layers {
	TERRAIN,
	PROP,
	HIGHLIGHT
}

func _ready():
	pass

func _process(delta: float) -> void:
	#print(get_tile_coords_from_world_pos(get_global_mouse_position()))
	var hovered_tile: Vector2i = get_tile_coords_from_world_pos(get_global_mouse_position())
	#highlight_layer.set_cell(old_hovered_tile, 2, Vector2i(0,1)) # TODO: Update this to dehighlight old tile
	WorldGrid.highlight_tile(hovered_tile)
	#highlight_layer.set_cell(hovered_tile, 2, Vector2i(0,0)) # TODO: Update this line to include highlighted tile border
	# TODO: Put what tile is in a specific spot
	#       This way we can change the tile sprite to a highlited sprite whenever.

func update_cell_sprite(tile_pos, sprite_info: TileInfo.TileSpriteInfo, layer: Layers):
	match layer:
		Layers.TERRAIN:
			terrain_layer.set_cell(tile_pos, sprite_info.source_id, sprite_info.atlas_coords)
	pass

func set_cell(tile_pos, tile_id, layer: int = 0):
	var atlas: Vector2i
	match tile_id:
		0: atlas = Vector2i(0,2)
		1: atlas = Vector2i(2,0)
		2: atlas = Vector2i(0,5)
		3: atlas = Vector2i(4,2)
		4: atlas = Vector2i(0,0)
		_: atlas = Vector2i(6,1)
	terrain_layer.set_cell(tile_pos, 1, atlas)

func get_world_pos_from_tile_coords(tile_pos: Vector2) -> Vector2:
	var tile_center_pos = terrain_layer.map_to_local(tile_pos)
	return self.to_global(tile_center_pos)

func get_tile_coords_from_world_pos(world_pos: Vector2) -> Vector2i:
	var tile_coords: Vector2i = terrain_layer.local_to_map(self.to_local(world_pos))
	return tile_coords
