class_name WorldGenerator
extends Node2D

signal chunk_generated(chunk_coords: Vector2i)

@onready var entity_manager: EntityManager = $"../EntityManager"
@onready var tile_map_manager: TileMapManager = $"../TileMapManager"

var tempurature_noise = FastNoiseLite.new()
var height_noise = FastNoiseLite.new()
var entity_noise = FastNoiseLite.new()

func _ready() -> void:
	tempurature_noise.seed = randi()
	tempurature_noise.frequency = 0.01
	
	height_noise.seed = randi()
	height_noise.frequency = 0.01
	
	entity_noise.seed = randi() + 20
	entity_noise.frequency = 0.5

func generate_chunk(chunk_coords: Vector2i):
	if WorldGrid.is_chunk_loaded(chunk_coords):
		# Exit early only if it's already marked loaded
		return
	
	print("Generating Chunk: ", chunk_coords)
	
	var chunk = WorldGrid.get_or_create_chunk(chunk_coords)

	for y in range(GridChunk.CHUNK_SIZE):
		for x in range(GridChunk.CHUNK_SIZE):
			var global_x = chunk_coords.x * GridChunk.CHUNK_SIZE + x
			var global_y = chunk_coords.y * GridChunk.CHUNK_SIZE + y
			var global_pos = Vector2i(global_x, global_y)
			var biome = get_biome_type(global_x, global_y)
			WorldGrid.set_biome(global_pos, biome)

			# Optional: set default walkability or visuals based on biome
			match biome:
				"water":
					WorldGrid.set_block(global_x, global_y, true)
				"mountain":
					# Spawn rocks
					#TODO: Update tree to be a new rock
					#TODO: Add rocks with ore in them
					if entity_noise.get_noise_2d(x, y) > 0.35:
						entity_manager.spawn_entity("rock", global_pos)
						pass
					pass
				"forest":
					if entity_noise.get_noise_2d(x, y) > 0.2:
						entity_manager.spawn_entity("tree", global_pos)
						pass
					pass

	WorldGrid.mark_chunk_loaded(chunk_coords)  # ✅ Now mark it as loaded AFTER generation
	chunk_generated.emit(chunk_coords)
	render_chunk(chunk_coords)

func render_chunk(chunk_coords: Vector2i):
	var chunk = WorldGrid.get_chunk(chunk_coords)
	if chunk == null:
		generate_chunk(chunk_coords)
	for y in range(GridChunk.CHUNK_SIZE):
		for x in range(GridChunk.CHUNK_SIZE):
			var global_x = chunk_coords.x * GridChunk.CHUNK_SIZE + x
			var global_y = chunk_coords.y * GridChunk.CHUNK_SIZE + y
			var tile_pos = Vector2i(global_x, global_y)
			var biome = chunk.biomes[y][x]
			var tile_id: int
			match biome:
				"plains": tile_id = 0
				"forest": tile_id = 1
				"mountain": tile_id = 2
				"water": tile_id = 3
				"grasslands": tile_id = 4
				_: tile_id = 0
			tile_map_manager.set_cell(tile_pos, tile_id)

func get_biome_type(x: int, y: int) -> String:
	var tempurature_value = tempurature_noise.get_noise_2d(x, y)
	var height_value = height_noise.get_noise_2d(x, y)
	
	if height_value < -0.4:
		return "water"
	elif height_value > 0.4:
		return "mountain"
	elif tempurature_value < -0.2:
		return "plains"
	elif tempurature_value < 0.3:
		return "forest"
	else:
		return "grasslands"
