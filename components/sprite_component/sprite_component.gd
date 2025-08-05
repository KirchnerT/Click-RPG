# TODO: Create Sprite Component Icon
class_name SpriteComponent
extends ComponentBase

@onready var sprite_to_show: Sprite2D = $SpriteToShow

var _texture_normal: Texture2D
var _texture_highlighted: Texture2D

func initialize(data: Dictionary = {}) -> void:
	var texture_normal: Texture2D = data.get("texture_normal")
	var texture_highlighted: Texture2D = data.get("texture_highlighted")
	
	_texture_normal = texture_normal
	_texture_highlighted = texture_highlighted
	unhighlight()

func highlight() -> void:
	sprite_to_show.texture = _texture_highlighted

func unhighlight() -> void:
	sprite_to_show.texture = _texture_normal
