class_name Player
extends CharacterBody2D

@export var move_speed: float = 0.1

var action_timer: Timer
var cur_action: Action = Action.NONE
var action_target: Entity

enum Action {
	NONE,
	CHOPPING,
	MINING,
	MOVING
}

func _ready() -> void:
	z_as_relative = false
	
	if !action_timer:
		action_timer = Timer.new()
		add_child(action_timer)
	action_timer.timeout.connect(action_timer_end)

func move_along_path(path: Array[Vector2i], tile_map_manager: TileMapManager) -> void:
	cur_action = Action.NONE
	if path.is_empty():
		return
	
	cur_action = Action.MOVING
	
	for step in path:
		var current_tile = tile_map_manager.get_tile_coords_from_world_pos(global_position)
		var global_target = tile_map_manager.get_world_pos_from_tile_coords(step)
		WorldGrid.move_entity(self, current_tile, step, global_target)
	
		await get_tree().create_timer(move_speed).timeout
	
	cur_action = Action.NONE

func interact(entity: Entity) -> void:
	match entity.type:
		Entity.Type.GENERIC:
			pass
		Entity.Type.TREE:
			chop_tree(entity)
		Entity.Type.ROCK:
			mine_rock(entity)

func chop_tree(entity: Entity) -> void:
	if entity == action_target && cur_action == Action.CHOPPING:
		return
	start_action(entity, Action.CHOPPING, 1)
	entity.interact(self)

func mine_rock(entity: Entity) -> void:
	if entity == action_target && cur_action == Action.MINING:
		return
	start_action(entity, Action.MINING, 1.5)
	entity.interact(self)

func action_timer_end() -> void:
	match (cur_action):
		Action.CHOPPING:
			if action_target:
				action_target.interact(self)
				action_timer.start()
			else:
				cur_action = Action.NONE
				action_target = null
		Action.MINING:
			if action_target:
				action_target.interact(self)
				action_timer.start()
			else:
				cur_action = Action.NONE
				action_target = null
		Action.NONE:
			cur_action = Action.NONE
			action_target = null
	pass

func update_activity(new_activity: Action) -> void:
	cur_action = new_activity

func start_action(new_action_target: Entity, action_to_start: Action, action_time: float) -> bool:
	if cur_action != Action.NONE:
		return false
	
	cur_action = action_to_start
	action_target = new_action_target
	action_timer.wait_time = action_time
	action_timer.one_shot = true
	action_timer.start()
	
	return true
