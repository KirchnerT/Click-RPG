class_name TileStatusManager
extends Node2D

@export var fire_scene: PackedScene
@onready var tile_map_manager: TileMapManager = $"../TileMapManager"

# Optional: Poll status updates every few seconds
const STATUS_UPDATE_INTERVAL := 10.0
var _update_timer := 0.0

func _process(delta: float) -> void:
	_update_timer += delta
	if _update_timer >= STATUS_UPDATE_INTERVAL:
		_update_timer = 0.0
		_update_tile_statuses()

func apply_status(global_pos: Vector2i, status_name: String, data := {}) -> void:
	#print("Applying status effect: ", status_name)
	#print("POS: ", global_pos)
	var current = WorldGrid.get_status(global_pos)
	
	match status_name:
		"fire":
			# Check for extinguishing
			if current.has("water"):
				WorldGrid.set_status(global_pos, "wet", {})  # becomes wet
				current.erase("fire")
			elif !current.has("fire"):
				# TODO Get the flamability of a tile to see if it goes up in flames EX: Stone != flammable
				# TODO Add status applications to entities and characters. EX: Set tree on fire
				WorldGrid.set_status(global_pos, "fire", data)
				var instance = fire_scene.instantiate()
				add_child(instance)
				instance.global_position = tile_map_manager.get_world_pos_from_tile_coords(global_pos)


		"water":
			if current.has("fire"):
				WorldGrid.set_status(global_pos, "wet", {})
				current.erase("fire")
			else:
				WorldGrid.set_status(global_pos, "water", data)

		"oil":
			WorldGrid.set_status(global_pos, "oil", data)

		"wet":
			WorldGrid.set_status(global_pos, "wet", data)

		_:
			WorldGrid.set_status(global_pos, status_name, data)

func remove_status(global_pos: Vector2i, status_name: String) -> void:
	print("Removing Status: ", global_pos)
	var current = WorldGrid.get_status(global_pos)
	current.erase(status_name)

func _update_tile_statuses() -> void:
	for chunk_coords in WorldGrid.loaded_chunks.keys():
		var chunk = WorldGrid.get_chunk(chunk_coords)
		if chunk == null:
			continue

		for y in range(GridChunk.CHUNK_SIZE):
			for x in range(GridChunk.CHUNK_SIZE):
				var local_pos = Vector2i(x, y)
				var global_pos = chunk_coords * GridChunk.CHUNK_SIZE + local_pos
				var statuses = chunk.get_status(local_pos)
				
				# Example logic: fire spreads
				if statuses.has("fire"):
					_try_spread_fire(global_pos)

				# Example: wet evaporates over time
				if statuses.has("wet"):
					if randf() < 0.1:
						remove_status(global_pos, "wet")

func _try_spread_fire(origin_pos: Vector2i):
	print("Trying to spread fire at: ", origin_pos)
	var neighbors = [
		Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1),
		Vector2i(1, 1), Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1)
	]
	for offset in neighbors:
		var neighbor = origin_pos + offset
		if !WorldGrid.is_tile_in_loaded_chunk(neighbor):
			continue

		var neighbor_status = WorldGrid.get_status(neighbor)

		# Fire spreads to flammable tiles (e.g., oil)
		if neighbor_status.has("oil"):
			apply_status(neighbor, "fire")

		# Fire does not spread to water or wet
		elif neighbor_status.has("water") or neighbor_status.has("wet"):
			continue

		# 10% chance to spread to neutral tile
		elif randf() < 0.1:
			apply_status(neighbor, "fire")
