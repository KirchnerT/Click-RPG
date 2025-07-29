extends Node2D

@onready var tile_map_manager: TileMapManager = $TileMapManager

var grid: WorldGrid
var pathfinder: AStarPathfinder
var player: Player

var is_moving: bool = false
var noise = FastNoiseLite.new()

func _ready() -> void:
	grid = WorldGrid.new()
	pathfinder = AStarPathfinder.new()
	
	player = get_tree().get_nodes_in_group("Player")[0]
	if player == null:
		printerr("PLAYER IS NULL IN TestWorld.gd")
	
	noise.seed = randi()
	noise.frequency = 0.01
	
	for x in range(-3, 4):
		for y in range(-3, 4):
			generate_chunk(Vector2i(x, y))
	
	
	# Populate tile map with players and structures
	# Spawn player
	move_entity(player, Vector2i(0,0), Vector2i(10,10))

func generate_chunk(chunk_coords: Vector2i):
	if grid.is_chunk_loaded(chunk_coords):
		return  # ✅ Exit early only if it's already marked loaded
	
	print("Generating Chunk: ", chunk_coords)
	
	var chunk = grid.get_or_create_chunk(chunk_coords)

	for y in range(GridChunk.CHUNK_SIZE):
		for x in range(GridChunk.CHUNK_SIZE):
			var global_x = chunk_coords.x * GridChunk.CHUNK_SIZE + x
			var global_y = chunk_coords.y * GridChunk.CHUNK_SIZE + y
			var global_pos = Vector2i(global_x, global_y)
			var biome = get_biome_type(global_x, global_y)
			grid.set_biome(global_pos, biome)

			# Optional: set default walkability or visuals based on biome
			match biome:
				"water":
					grid.set_block(global_x, global_y, true)
				"mountain":
					grid.set_block(global_x, global_y, true)

	grid.mark_chunk_loaded(chunk_coords)  # ✅ Now mark it as loaded AFTER generation
	render_chunk(chunk_coords)

func render_chunk(chunk_coords: Vector2i):
	var chunk = grid.get_chunk(chunk_coords)
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
				_: tile_id = 0
			tile_map_manager.set_cell(tile_pos, tile_id)

func get_biome_type(x: int, y: int) -> String:
	var value = noise.get_noise_2d(x, y)
	if value < -0.5:
		return "water"
	elif value < 0:
		return "plains"
	elif value < 0.4:
		return "forest"
	else:
		return "mountain"

func move_entity(entity: Node2D, from: Vector2i, to: Vector2i):
	grid.remove_entity(from)
	grid.set_entity(to, entity)
	entity.global_position = tile_map_manager.get_world_pos_from_tile_coords(to)
	
func _input(event):
	if (event.is_action_pressed("CHARACTER_ACTION_1")) && !is_moving:
		var mouse_pos: Vector2i = tile_map_manager.get_tile_coords_from_world_pos(get_global_mouse_position())
		
		var player_pos_in_map: Vector2i = tile_map_manager.get_tile_coords_from_world_pos(player.global_position)
		var path = pathfinder.find_path(grid, player_pos_in_map, mouse_pos)
		print("Path:", path)
		
		if path != []:
			move(player, path)
			load_chunks_around(path[path.size()-1])

func move(entity: Node2D, path: Array[Vector2i]):
	if !is_tile_valid_for_path(path[path.size()-1]):
		return
	
	is_moving = true
	
	for next_step in path:
		move_entity(entity, tile_map_manager.get_tile_coords_from_world_pos(entity.global_position), next_step)
		await get_tree().create_timer(0.1).timeout
	
	is_moving = false

func is_tile_valid_for_path(pos: Vector2i) -> bool:
	return grid.is_tile_in_loaded_chunk(pos) and grid.is_walkable(pos.x, pos.y)

func load_chunks_around(center_pos: Vector2i, radius: int = 3):
	var center_chunk = grid._get_chunk_coords(center_pos)
	for y in range(-radius, radius+1):
		for x in range(-radius, radius+1):
			var chunk_coords = center_chunk + Vector2i(x, y)
			if not grid.is_chunk_loaded(chunk_coords):
				generate_chunk(chunk_coords)
