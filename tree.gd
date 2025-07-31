class_name TestTree
extends Entity

@onready var health_component: HealthComponent = $HealthComponent

func hurt(damage: int):
	health_component.update_cur_health(damage * -1)

#func interact(by: Node) -> void:
	#print("Chopping tree...")
	#health -= 1
	#if health <= 0:
		#queue_free()
		#WorldGrid.remove_entity(tile_pos)
		#print("Tree removed!")
