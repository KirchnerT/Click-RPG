class_name PlanterBox
extends Entity

@onready var health_component: HealthComponent = $HealthComponent
@onready var sprite_component: SpriteComponent = $SpriteComponent
@onready var interact_component: Control = $InteractComponent

@export_category("Components")

@export_group("SpriteComponent")
@export var texture_normal: AtlasTexture
@export var texture_highlighted: AtlasTexture

@export_group("Health Component")
@export var max_health: int

func _ready() -> void:
	sprite_component.initialize({
		"texture_normal": texture_normal, 
		"texture_highlighted": texture_highlighted})
	health_component.initialize({"max_health": max_health})
	super()

func hurt(damage: int, source: Node2D):
	health_component.update_cur_health(damage * -1, source)

func interact(by: Node) -> void:
	interact_component.visible = true
	print("Planter interact not setup")
	# TODO: Check player inventory
	# TODO: Add button options for each
	# TODO: connect their signals

func uninteract(by: Node) -> void:
	interact_component.visible = false

func _on_health_component_is_dead(by: Node) -> void:
	print("Planter Box is dead by :", by.name)
	WorldGrid.remove_entity(tile_pos)
	queue_free()

func highlight() -> void:
	sprite_component.highlight()

func unhighlight() -> void:
	sprite_component.unhighlight()

#TODO: Add functions for different button presses
