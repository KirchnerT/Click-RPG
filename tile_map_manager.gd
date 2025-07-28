class_name TileMapManager
extends Node2D

const CHUNK_SIZE = 32
const WORLD_WIDTH_CHUNKS = 5
const WORLD_HEIGHT_CHUNKS = 5

# Noise scale (inverse of frequency)
const NOISE_SCALE = 0.01

@onready var terrain_layer: TileMapLayer = $TerrainLayer


@onready var astar = AStar2D.new()
@onready var used_cells: Array[Vector2i]
var path: PackedVector2Array


@export var biome_tiles: Dictionary

var height_noise: FastNoiseLite
var temp_noise: FastNoiseLite
var moisture_noise: FastNoiseLite

class Tile_Data:
	var height: float
	var temperature: float
	var moisture: float
	var biome: String

# Chunk cache: Dictionary<Vector2i(chunk_x, chunk_y), Dictionary<Vector2i(local_x, local_y), TileData>>
var chunk_data: Dictionary = {}

func _ready():
	randomize()
	_initialize_noise()
	_generate_all_chunks()
	_render_chunks()
	
	# AStar Stuff
	used_cells = terrain_layer.get_used_cells()
	_add_points()
	_connect_points()

func _add_points():
	for cell in used_cells:
		astar.add_point(id(cell), cell, 1.0)

func _connect_points():
	for cell: Vector2i in used_cells:
		# RIGHT, LEFT, DOWN, UP
		var neighbors = [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]
		for neighbor: Vector2i in neighbors:
			var next_cell = cell + neighbor
			if used_cells.has(next_cell):
				astar.connect_points(id(cell), id(next_cell), false)

func _get_path(start: Vector2i, end: Vector2i) -> PackedVector2Array:
	path = astar.get_point_path(id(start), id(end))
	path.remove_at(0)
	return path

# Cantor pairing function
func id(point):
	var a = point.x
	var b = point.y
	# Formula that will NEVER have duplicate ids
	return (a + b) * (a + b + 1) / 2 + b

func _initialize_noise():
	height_noise = FastNoiseLite.new()
	height_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	height_noise.seed = randi()
	height_noise.frequency = NOISE_SCALE

	temp_noise = FastNoiseLite.new()
	temp_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	temp_noise.seed = randi()
	temp_noise.frequency = NOISE_SCALE
	
	moisture_noise = FastNoiseLite.new()
	moisture_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	moisture_noise.seed = randi()
	moisture_noise.frequency = NOISE_SCALE

func _generate_all_chunks():
	for cy in WORLD_HEIGHT_CHUNKS:
		for cx in WORLD_WIDTH_CHUNKS:
			var chunk = _generate_chunk(Vector2i(cx, cy))
			chunk_data[Vector2i(cx, cy)] = chunk

func _generate_chunk(chunk_coord: Vector2i) -> Dictionary:
	var chunk = {}
	for y in CHUNK_SIZE:
		for x in CHUNK_SIZE:
			var wx = chunk_coord.x * CHUNK_SIZE + x
			var wy = chunk_coord.y * CHUNK_SIZE + y

			var tile = Tile_Data.new()
			tile.height = height_noise.get_noise_2d(wx, wy)
			tile.temperature = temp_noise.get_noise_2d(wx + 5000, wy + 5000)
			tile.moisture = moisture_noise.get_noise_2d(wx + 10000, wy + 10000)
			tile.biome = get_biome(tile.height, tile.temperature, tile.moisture)
			
			chunk[Vector2i(x, y)] = tile
	return chunk

func get_biome(height: float, temp: float, moisture: float) -> String:
	if moisture < -0.2:
		return "ShallowWater"
	elif temp < -0.2:
		return "Snow"
	elif height > 0:
		return "Forest"
	else:
		return "Plains"

func biome_to_tile_id(biome: String) -> Vector2i:
	return biome_tiles.get(biome, biome_tiles.get("Forest"))

func _render_chunks():
	for chunk_pos in chunk_data:
		var chunk = chunk_data[chunk_pos]
		for local_pos in chunk:
			var tile = chunk[local_pos]
			var world_pos = chunk_pos * CHUNK_SIZE + local_pos

			var tile_id: Vector2i = biome_to_tile_id(tile.biome)
			terrain_layer.set_cell(world_pos, 1, tile_id)

func get_world_pos_from_tile_coords(tile_pos: Vector2) -> Vector2:
	var tile_center_pos = terrain_layer.map_to_local(tile_pos)
	return self.to_global(tile_center_pos)

func get_tile_coords_from_world_pos(world_pos: Vector2) -> Vector2i:
	var tile_coords: Vector2i = terrain_layer.local_to_map(self.to_local(world_pos))
	return tile_coords
