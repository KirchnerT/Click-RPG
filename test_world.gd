extends Node2D

@onready var character: Player = $Character
@onready var tile_map_manager: TileMapManager = $TileMapManager
@onready var movement_line: Line2D = Line2D.new()

var is_moving: bool = false

func _ready() -> void:
	# Populate tile map with characters and structures
	character.global_position = tile_map_manager.get_world_pos_from_tile_coords(Vector2(1,2))

func _input(event):
	if (event is InputEventMouseButton && event.is_pressed() && event.button_index == MOUSE_BUTTON_LEFT) && !is_moving:
		var mouse_pos: Vector2i = tile_map_manager.get_tile_coords_from_world_pos(get_global_mouse_position())
		if tile_map_manager.used_cells.has(mouse_pos):
			var player_pos_in_map: Vector2i = tile_map_manager.get_tile_coords_from_world_pos(character.global_position)
			tile_map_manager._get_path(player_pos_in_map, mouse_pos)
			move()

func move():
	is_moving = true
	
	for p in tile_map_manager.path:
		character.move_to(tile_map_manager.get_world_pos_from_tile_coords(p))
		await get_tree().create_timer(0.1).timeout
	
	is_moving = false
