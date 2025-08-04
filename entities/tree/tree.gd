class_name TestTree
extends Entity

@onready var health_component: HealthComponent = $HealthComponent
@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	super()

func hurt(damage: int, source: Node2D):
	health_component.update_cur_health(damage * -1, source)

func interact(by: Node) -> void:
	chop(by)

func chop(source: Node2D) -> void:
	#TODO: Add resource to player inventory
	print("CHOPPPPP")
	hurt(1, source)

func _on_health_component_is_dead(by: Node) -> void:
	print("Tree is dead by :", by.name)
	WorldGrid.remove_entity(tile_pos)
	queue_free()

func highlight() -> void:
	sprite_2d.modulate = Color.BLACK

func unhighlight() -> void:
	sprite_2d.modulate = Color.WHITE
