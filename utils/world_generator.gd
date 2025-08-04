class_name WorldGenerator
extends Node2D

signal chunk_generated(chunk_coords: Vector2i)

@onready var entity_manager: EntityManager = $"../EntityManager"
@onready var tile_map_manager: TileMapManager = $"../TileMapManager"
@onready var tile_status_manager: TileStatusManager = $"../TileStatusManager"

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
	
	#print("Generating Chunk: ", chunk_coords)
	
	var chunk = WorldGrid.get_or_create_chunk(chunk_coords)

	for y in range(GridChunk.CHUNK_SIZE):
		for x in range(GridChunk.CHUNK_SIZE):
			var global_x = chunk_coords.x * GridChunk.CHUNK_SIZE + x
			var global_y = chunk_coords.y * GridChunk.CHUNK_SIZE + y
			var global_pos = Vector2i(global_x, global_y)
			var biome = get_biome_type(global_x, global_y)
			WorldGrid.set_biome(global_pos, biome)
			# TODO: WorldGrid.set_tile_sprite(global_pos) set sprite to random biome tile
			
			# Optional: set default walkability or visuals based on biome
			match biome:
				TileInfo.Biomes.WATER:
					WorldGrid.set_block(global_x, global_y, true)
					tile_status_manager.apply_status(global_pos, "water")
				TileInfo.Biomes.MOUNTAIN:
					# Spawn rocks
					#TODO: Add rocks with ore in them
					if entity_noise.get_noise_2d(x, y) > 0.35:
						entity_manager.spawn_entity("rock", global_pos)
						pass
					pass
				TileInfo.Biomes.FOREST:
					if entity_noise.get_noise_2d(x, y) > 0.2:
						entity_manager.spawn_entity("tree", global_pos)
						pass
					pass

	WorldGrid.mark_chunk_loaded(chunk_coords)
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
			var biome = chunk.get_biome(Vector2i(x, y))
			var tile_id: int
			match biome:
				TileInfo.Biomes.PLAINS: tile_id = 0
				TileInfo.Biomes.FOREST: tile_id = 1
				TileInfo.Biomes.MOUNTAIN: tile_id = 2
				TileInfo.Biomes.WATER: tile_id = 3
				TileInfo.Biomes.GRASSLANDS: tile_id = 4
				_: tile_id = 0
			tile_map_manager.set_cell(tile_pos, tile_id)

func get_biome_type(x: int, y: int) -> TileInfo.Biomes:
	var tempurature_value = tempurature_noise.get_noise_2d(x, y)
	var height_value = height_noise.get_noise_2d(x, y)
	
	if height_value < -0.4:
		return TileInfo.Biomes.WATER
	elif height_value > 0.4:
		return TileInfo.Biomes.MOUNTAIN
	elif tempurature_value < -0.2:
		return TileInfo.Biomes.PLAINS
	elif tempurature_value < 0.3:
		return TileInfo.Biomes.FOREST
	else:
		return TileInfo.Biomes.GRASSLANDS

func load_chunks_around(center_pos: Vector2i, radius: int = 4):
	var center_chunk = WorldGrid._get_chunk_coords(center_pos)
	for y in range(-radius, radius+1):
		for x in range(-radius, radius+1):
			var chunk_coords = center_chunk + Vector2i(x, y)
			if not WorldGrid.is_chunk_loaded(chunk_coords):
				generate_chunk(chunk_coords)
