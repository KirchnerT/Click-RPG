class_name TileMapManager
extends Node2D

const CHUNK_SIZE = 32
const WORLD_WIDTH_CHUNKS = 5
const WORLD_HEIGHT_CHUNKS = 5

# Noise scale (inverse of frequency)
const NOISE_SCALE = 0.01

@onready var terrain_layer: TileMapLayer = $TerrainLayer
@onready var prop_layer: TileMapLayer = $PropLayer

@export var biome_tiles: Dictionary

var height_noise: FastNoiseLite
var temp_noise: FastNoiseLite
var moisture_noise: FastNoiseLite

func _ready():
	randomize()
	_initialize_noise()

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

func set_cell(tile_pos, tile_id):
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
