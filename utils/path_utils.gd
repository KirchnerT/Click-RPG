# PathUtils.gd
extends Node

static var directions_8 := [
	Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1),
	Vector2i(1, 1), Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1)
]

static var directions_4 := [
	Vector2i(1, 0), Vector2i(-1, 0),
	Vector2i(0, 1), Vector2i(0, -1)
]

# Basic walkable check
static func is_tile_valid_for_path(pos: Vector2i) -> bool:
	return WorldGrid.is_tile_in_loaded_chunk(pos) and WorldGrid.is_walkable(pos.x, pos.y)

# Find reachable tiles around a point using A* pathfinder
static func find_best_reachable_tile_around(
	target: Vector2i,
	from: Vector2i,
	pathfinder: AStarPathfinder
) -> Array[Vector2i]:
	var best_path: Array[Vector2i] = []
	var min_len := INF

	for offset: Vector2i in directions_8:
		var neighbor: Vector2i = target + offset
		if is_tile_valid_for_path(neighbor) and WorldGrid.get_entity(neighbor) == null:
			var path := pathfinder.find_path(from, neighbor)
			if path.size() > 0 and path.size() < min_len:
				best_path = path
				min_len = path.size()
	
	return best_path

# Check if two positions are adjacent (but not equal)
static func is_adjacent(a: Vector2i, b: Vector2i) -> bool:
	return abs(a.x - b.x) <= 1 and abs(a.y - b.y) <= 1 and a != b

# --- FLOOD FILL ---
# Returns all reachable tiles from start within given range (steps).
static func flood_fill(start: Vector2i, max_steps: int = 999, allow_diagonal := false) -> Array[Vector2i]:
	var visited := {}
	var queue := [start]
	var results := []

	var dirs = directions_8 if allow_diagonal else directions_4
	visited[start] = 0
	
	while not queue.is_empty():
		var current = queue.pop_front()
		var steps = visited[current]
		results.append(current)

		if steps >= max_steps:
			continue

		for offset in dirs:
			var neighbor = current + offset
			if not visited.has(neighbor) and is_tile_valid_for_path(neighbor):
				visited[neighbor] = steps + 1
				queue.append(neighbor)
	
	return results

# --- DIJKSTRA ---
# Returns a map of cost-to-reach for each tile from the start tile.
static func dijkstra(start: Vector2i, max_cost: int = 999, allow_diagonal := false) -> Dictionary:
	var cost_map := {}
	var frontier := []
	var dirs = directions_8 if allow_diagonal else directions_4

	cost_map[start] = 0
	frontier.push_back(start)

	while frontier.size() > 0:
		var current = frontier.pop_front()
		var current_cost = cost_map[current]

		if current_cost >= max_cost:
			continue

		for offset in dirs:
			var neighbor = current + offset
			var move_cost = 1 # You could add per-tile cost logic here
			var total_cost = current_cost + move_cost

			if is_tile_valid_for_path(neighbor):
				if not cost_map.has(neighbor) or total_cost < cost_map[neighbor]:
					cost_map[neighbor] = total_cost
					frontier.push_back(neighbor)

	return cost_map

# TODO: Implement weights in WorldGrid & apply weights to biomes/pathfinding
