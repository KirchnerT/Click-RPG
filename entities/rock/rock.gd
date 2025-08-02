class_name Rock
extends Entity

@onready var health_component: HealthComponent = $HealthComponent

func hurt(damage: int, source: Node2D):
	health_component.update_cur_health(damage * -1, source)

func interact(by: Node) -> void:
	print("MINE")
	mine(by)

func mine(source: Node2D) -> void:
	#TODO: Add resource to player inventory
	hurt(1, source)

func _on_health_component_is_dead(by: Node) -> void:
	print("Rock is dead by :", by.name)
	WorldGrid.remove_entity(tile_pos)
	queue_free()
