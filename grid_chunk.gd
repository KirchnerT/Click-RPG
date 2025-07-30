# GridChunk.gd
class_name GridChunk

const CHUNK_SIZE = 16
var tiles: Array = []
var biomes: Array = []

var entities_by_tile: Dictionary = {}

func _init():
	for y in range(CHUNK_SIZE):
		tiles.append([])
		biomes.append([])
		for x in range(CHUNK_SIZE):
			tiles[y].append(0)  # 0 = walkable
			biomes[y].append("forest")  # default biome

func is_walkable(local_pos: Vector2i) -> bool:
	if get_entity(local_pos):
		return 1 # Not walkable
	return is_inside(local_pos) and tiles[local_pos.y][local_pos.x] == 0

func is_inside(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.y >= 0 and pos.x < CHUNK_SIZE and pos.y < CHUNK_SIZE

func set_block(local_pos: Vector2i, blocked: bool):
	if is_inside(local_pos):
		tiles[local_pos.y][local_pos.x] = 1 if blocked else 0

func set_entity(local_pos: Vector2i, entity: Object) -> void:
	if is_inside(local_pos):
		entities_by_tile[local_pos] = entity

func remove_entity(local_pos: Vector2i) -> void:
	entities_by_tile.erase(local_pos)

func get_entity(local_pos: Vector2i) -> Object:
	return entities_by_tile.get(local_pos, null)

func set_biome(local_pos: Vector2i, biome_name: String):
	if is_inside(local_pos):
		biomes[local_pos.y][local_pos.x] = biome_name

func get_biome(local_pos: Vector2i) -> String:
	if is_inside(local_pos):
		return biomes[local_pos.y][local_pos.x]
	return "unknown"
