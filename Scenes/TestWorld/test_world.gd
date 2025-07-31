extends Node2D

@onready var tile_map_manager: TileMapManager = $TileMapManager
@onready var camera_2d: CameraMovement = $Camera2D
@onready var world_generator: Node2D = $WorldGenerator
@onready var input_controller: InputController = $InputController

#var grid: WorldGrid
var pathfinder: AStarPathfinder
var player: Player

func _ready() -> void:
#	grid = WorldGrid.new()
	pathfinder = AStarPathfinder.new()
	input_controller.pathfinder = pathfinder
	
	player = get_tree().get_nodes_in_group("Player")[0]
	if player == null:
		printerr("PLAYER IS NULL IN TestWorld.gd")
	
	# TODO: Make a whole map generation script on load of new world
	
	await generate_starting_area()
	#spawn_player()
	# Spawn player 
	# Search for nearest grasslands near (0,0)
	# Make sure all surrounding tiles are 1: valid 2: grasslands
	WorldGrid.move_entity(player, Vector2i(0,0), Vector2i(10,10), tile_map_manager.get_world_pos_from_tile_coords(Vector2i(10,10)))
	camera_2d.global_position = player.global_position

func generate_starting_area():
	for x in range(-3, 4):
		for y in range(-3, 4):
			world_generator.generate_chunk(Vector2i(x, y))
	await get_tree().process_frame  # Ensure chunk data is ready
