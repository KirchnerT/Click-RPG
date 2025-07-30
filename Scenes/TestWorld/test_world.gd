extends Node2D

@onready var tile_map_manager: TileMapManager = $TileMapManager
@onready var camera_2d: CameraMovement = $Camera2D

@export var forest_tree: PackedScene

var grid: WorldGrid
var pathfinder: AStarPathfinder
var player: Player

var is_moving: bool = false
var tempurature_noise = FastNoiseLite.new()
var height_noise = FastNoiseLite.new()
var entity_noise = FastNoiseLite.new()

func _ready() -> void:
	grid = WorldGrid.new()
	pathfinder = AStarPathfinder.new()
	
	player = get_tree().get_nodes_in_group("Player")[0]
	if player == null:
		printerr("PLAYER IS NULL IN TestWorld.gd")
	
	tempurature_noise.seed = randi()
	tempurature_noise.frequency = 0.01
	
	height_noise.seed = randi()
	height_noise.frequency = 0.01
	
	entity_noise.seed = randi() + 20
	entity_noise.frequency = 0.5
	
	# TODO: Make a whole map generation script on load of new world
	for x in range(-6, 7):
		for y in range(-6, 7):
			generate_chunk(Vector2i(x, y))
	
	# Spawn player 
	# Search for nearest grasslands near (0,0)
	# Make sure all surrounding tiles are 1: valid 2: grasslands
	move_entity(player, Vector2i(0,0), Vector2i(10,10))
	camera_2d.global_position = player.global_position

func generate_chunk(chunk_coords: Vector2i):
	if grid.is_chunk_loaded(chunk_coords):
		# Exit early only if it's already marked loaded
		return
	
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
				"forest":
					# Spawn Test Tree
					if entity_noise.get_noise_2d(x, y) > 0.2:
						var new_tree: Node2D = forest_tree.instantiate()
						self.add_child(new_tree)
						move_entity(new_tree, Vector2i(0, 0), Vector2i(global_x, global_y))
						pass
					pass

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

func move_entity(entity: Node2D, from: Vector2i, to: Vector2i):
	grid.remove_entity(from)
	grid.set_entity(to, entity)
	entity.global_position = tile_map_manager.get_world_pos_from_tile_coords(to)
	
	var tile_y = entity.global_position.y
	entity.z_index = int(tile_y)
	
func _input(event):
	if (event.is_action_pressed("CHARACTER_ACTION_1")) && !is_moving:
		_use_player_action_1()

func _use_player_action_1():
	var mouse_pos: Vector2i = tile_map_manager.get_tile_coords_from_world_pos(get_global_mouse_position())
	var player_pos_in_map: Vector2i = tile_map_manager.get_tile_coords_from_world_pos(player.global_position)
	
	if mouse_pos == player_pos_in_map:
		return
	
	# Check if tile has entity
	var entity_on_grid: Node2D = grid.get_entity(mouse_pos)
	if entity_on_grid != null:
		## Find closest path
		var closest_path: Array = find_best_reachable_tile_around(grid, mouse_pos, player_pos_in_map)
		# Check is a closest path was found
		if closest_path != []:
			load_chunks_around(closest_path[closest_path.size()-1])
			await move(player, closest_path)
			# do action
			entity_on_grid.test()
	else:
		if !grid.is_walkable(mouse_pos.x, mouse_pos.y):
			return
		
		var path = pathfinder.find_path(grid, player_pos_in_map, mouse_pos)
		print("Path:", path)
		
		if path != []:
			move(player, path)
			load_chunks_around(path[path.size()-1])

func find_best_reachable_tile_around(grid: WorldGrid, target: Vector2i, from: Vector2i) -> Array:
	var best_path: Array[Vector2i] = []
	var min_len = INF
	var dirs = [
		Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1),
		Vector2i(1, 1), Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1)
	]

	for offset in dirs:
		var neighbor = target + offset
		if grid.is_tile_in_loaded_chunk(neighbor) and grid.is_walkable(neighbor.x, neighbor.y) and grid.get_entity(neighbor) == null:
			var path = AStarPathfinder.new().find_path(grid, from, neighbor)
			if path.size() > 0 and path.size() < min_len:
				best_path = path
				min_len = path.size()

	return best_path

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

func load_chunks_around(center_pos: Vector2i, radius: int = 4):
	var center_chunk = grid._get_chunk_coords(center_pos)
	for y in range(-radius, radius+1):
		for x in range(-radius, radius+1):
			var chunk_coords = center_chunk + Vector2i(x, y)
			if not grid.is_chunk_loaded(chunk_coords):
				generate_chunk(chunk_coords)
