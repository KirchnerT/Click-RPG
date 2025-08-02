extends Node2D

var loaded_chunks:= {}

const CHUNK_SIZE = 16
var chunks: Dictionary = {}

func _init():
	pass

func _ready():
	print("WorldGrid initialized")

func _get_chunk_coords(global_pos: Vector2i) -> Vector2i:
	var chunk_x = global_pos.x / CHUNK_SIZE
	if global_pos.x < 0 and global_pos.x % CHUNK_SIZE != 0:
		chunk_x -= 1

	var chunk_y = global_pos.y / CHUNK_SIZE
	if global_pos.y < 0 and global_pos.y % CHUNK_SIZE != 0:
		chunk_y -= 1

	return Vector2i(chunk_x, chunk_y)

func _get_local_pos(global_pos: Vector2i) -> Vector2i:
	var x = global_pos.x % CHUNK_SIZE
	if x < 0:
		x += CHUNK_SIZE

	var y = global_pos.y % CHUNK_SIZE
	if y < 0:
		y += CHUNK_SIZE

	return Vector2i(x, y)

func get_or_create_chunk(chunk_coords: Vector2i) -> GridChunk:
	if not chunks.has(chunk_coords):
		chunks[chunk_coords] = GridChunk.new()
	return chunks[chunk_coords]

func get_chunk(chunk_coords: Vector2i) -> GridChunk:
	if chunks.has(chunk_coords):
		return chunks[chunk_coords]
	return null

func is_walkable(x: int, y: int) -> bool:
	var global_pos = Vector2i(x, y)
	var chunk_coords = _get_chunk_coords(global_pos)
	var local_pos = _get_local_pos(global_pos)
	var chunk = chunks.get(chunk_coords)
	if chunk:
		return chunk.is_walkable(local_pos)
	return false  # Not walkable if chunk isn't loaded

func set_block(x: int, y: int, blocked: bool):
	var global_pos = Vector2i(x, y)
	var chunk_coords = _get_chunk_coords(global_pos)
	var local_pos = _get_local_pos(global_pos)
	var chunk = get_or_create_chunk(chunk_coords)
	chunk.set_block(local_pos, blocked)

func set_entity(global_pos: Vector2i, entity: Object, override: bool = false):
	var chunk_coords = _get_chunk_coords(global_pos)
	var local_pos = _get_local_pos(global_pos)
	
	if !get_entity(global_pos) || override:
		var chunk = get_or_create_chunk(chunk_coords)
		chunk.set_entity(local_pos, entity)
		entity.z_index = int(entity.global_position.y)
	else:
		printerr("ERR: Tried to set entity on filled tile")

func remove_entity(global_pos: Vector2i):
	var chunk_coords = _get_chunk_coords(global_pos)
	var local_pos = _get_local_pos(global_pos)
	var chunk = chunks.get(chunk_coords)
	if chunk:
		chunk.remove_entity(local_pos)

func get_entity(global_pos: Vector2i) -> Object:
	var chunk_coords = _get_chunk_coords(global_pos)
	var local_pos = _get_local_pos(global_pos)
	var chunk = chunks.get(chunk_coords)
	if chunk:
		return chunk.get_entity(local_pos)
	return null

func set_biome(global_pos: Vector2i, biome: TileInfo.Biomes):
	var chunk_coords = _get_chunk_coords(global_pos)
	var local_pos = _get_local_pos(global_pos)
	var chunk = get_or_create_chunk(chunk_coords)
	chunk.set_biome(local_pos, biome)

func get_biome(global_pos: Vector2i) -> TileInfo.Biomes:
	var chunk_coords = _get_chunk_coords(global_pos)
	var local_pos = _get_local_pos(global_pos)
	var chunk = chunks.get(chunk_coords)
	if chunk:
		return chunk.get_biome(local_pos)
	return TileInfo.Biomes.UNKNOWN

func mark_chunk_loaded(chunk_coords: Vector2i):
	loaded_chunks[chunk_coords] = true

func is_chunk_loaded(chunk_coords: Vector2i) -> bool:
	return loaded_chunks.has(chunk_coords)

func is_tile_in_loaded_chunk(global_pos: Vector2i) -> bool:
	var chunk_coords = _get_chunk_coords(global_pos)
	return is_chunk_loaded(chunk_coords)

func move_entity(entity: Node2D, from: Vector2i, to: Vector2i, to_global_pos: Vector2i):
	remove_entity(from)
	set_entity(to, entity)
	entity.global_position = to_global_pos
	
	var tile_y = entity.global_position.y
	entity.z_index = int(tile_y)

func is_tile_reachable(global_pos: Vector2i) -> bool:
	return is_tile_in_loaded_chunk(global_pos) and is_walkable(global_pos.x, global_pos.y) and get_entity(global_pos) == null

func set_status(global_pos: Vector2i, status_name: String, value: Variant):
	var chunk_coords = _get_chunk_coords(global_pos)
	var local_pos = _get_local_pos(global_pos)
	var chunk = get_or_create_chunk(chunk_coords)
	chunk.set_status(local_pos, status_name, value)

func get_status(global_pos: Vector2i) -> Dictionary:
	var chunk_coords = _get_chunk_coords(global_pos)
	var local_pos = _get_local_pos(global_pos)
	var chunk = get_chunk(chunk_coords)
	if chunk:
		return chunk.get_status(local_pos)
	return {}
