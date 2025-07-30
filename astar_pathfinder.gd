class_name AStarPathfinder
extends Node

const INF = 999999

func find_path(grid: WorldGrid, start: Vector2i, end: Vector2i) -> Array:
	if not grid.is_tile_in_loaded_chunk(start) or not grid.is_tile_in_loaded_chunk(end):
		print("Start or end not in loaded chunk")
		return []

	var open_set = [start]
	var came_from = {}
	var g_score = {start: 0}
	var f_score = {start: heuristic(start, end)}

	var max_iterations = 10000
	var iterations = 0

	while open_set.size() > 0:
		if iterations > max_iterations:
			print("A* iteration limit reached")
			break
		iterations += 1

		open_set.sort_custom(func(a, b): return f_score.get(a, INF) < f_score.get(b, INF))
		var current = open_set[0]
		if current == end:
			return reconstruct_path(came_from, current)

		open_set.remove_at(0)
		for neighbor in get_neighbors(grid, current):
			var tentative_g = g_score.get(current, INF) + 1
			if tentative_g < g_score.get(neighbor, INF):
				came_from[neighbor] = current
				g_score[neighbor] = tentative_g
				f_score[neighbor] = tentative_g + heuristic(neighbor, end)
				if neighbor not in open_set:
					open_set.append(neighbor)

	return []

func heuristic(a: Vector2i, b: Vector2i) -> int:
	return abs(a.x - b.x) + abs(a.y - b.y)  # Manhattan distance

func get_neighbors(grid: WorldGrid, pos: Vector2i) -> Array:
	var dirs = [
		Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1),
		Vector2i(1, 1), Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1)
	]
	var result = []
	for dir in dirs:
		var n = pos + dir

		if not grid.is_tile_in_loaded_chunk(n):
			# Only print once per frame maybe, or debug level
			print("Skipping neighbor ", n, " (not loaded)")
			continue

		if grid.is_walkable(n.x, n.y) and grid.get_entity(n) == null:
			result.append(n)
	return result

func reconstruct_path(came_from: Dictionary, current: Vector2i) -> Array:
	var path: Array[Vector2i] = [current]
	while current in came_from:
		current = came_from[current]
		path.push_front(current)
	return path
