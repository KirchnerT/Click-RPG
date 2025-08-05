extends NinePatchRect

@onready var v_box_container: VBoxContainer = $VBoxContainer

var item_slot_scene = preload("res://temp_button_scene.tscn")
var max_rect_size_y = 1000 # some int value 
var margin = 6

func _ready() -> void:
	add_item_slot()
	add_item_slot()

func add_item_slot():
	var new_item_slot = item_slot_scene.instantiate()
	v_box_container.add_child(new_item_slot)
	if size.y + new_item_slot.size.y < max_rect_size_y:
		size.y += new_item_slot.size.y + margin
	if new_item_slot.size.x > size.x:
		size.x = new_item_slot.size.x + margin
