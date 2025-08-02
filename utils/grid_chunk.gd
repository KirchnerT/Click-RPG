class_name GridChunk

const CHUNK_SIZE = 16

var tiles_info: Dictionary = {} # key: local position : Data TileInfo

func _init():
	for y in range(CHUNK_SIZE):
		for x in range(CHUNK_SIZE):
			var local_pos : Vector2i = Vector2i(x, y)
			tiles_info[local_pos] = TileInfo.new()

func is_walkable(local_pos: Vector2i) -> bool:
	if get_entity(local_pos):
		return 1 # Not walkable
	var tile_info: TileInfo = tiles_info[local_pos]
	return is_inside(local_pos) and tile_info.is_walkable

func is_inside(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.y >= 0 and pos.x < CHUNK_SIZE and pos.y < CHUNK_SIZE

func set_block(local_pos: Vector2i, blocked: bool):
	if is_inside(local_pos):
		var tile_info: TileInfo = tiles_info[local_pos]
		tile_info.is_walkable = false if blocked else true

func set_entity(local_pos: Vector2i, entity: Object) -> void:
	if is_inside(local_pos):
		var tile_info: TileInfo = tiles_info[local_pos]
		tile_info.entity = entity

func remove_entity(local_pos: Vector2i) -> void:
	var tile_info: TileInfo = tiles_info[local_pos]
	tile_info.entity = null

func get_entity(local_pos: Vector2i) -> Object:
	var tile_info: TileInfo = tiles_info[local_pos]
	return tile_info.entity

func set_biome(local_pos: Vector2i, biome: TileInfo.Biomes):
	if is_inside(local_pos):
		var tile_info: TileInfo = tiles_info[local_pos]
		tile_info.biome = biome
		#biomes[local_pos.y][local_pos.x] = biome_name

func get_biome(local_pos: Vector2i) -> TileInfo.Biomes:
	if is_inside(local_pos):
		var tile_info: TileInfo = tiles_info[local_pos]
		return tile_info.biome
	return TileInfo.Biomes.UNKNOWN

func set_status(local_pos: Vector2i, status_name: String, value: Variant):
	if is_inside(local_pos):
		var tile_info: TileInfo = tiles_info[local_pos]
		tile_info.status_effects[status_name] = value

func get_status(local_pos: Vector2i) -> Dictionary:
	if is_inside(local_pos):
		var tile_info: TileInfo = tiles_info[local_pos]
		return tile_info.status_effects
	return {}
