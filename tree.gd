class_name TestTree
extends Node2D

@onready var health_component: HealthComponent = $HealthComponent

func hurt(damage: int):
	health_component.update_cur_health(damage * -1)

func test():
	print("OW TREE")
