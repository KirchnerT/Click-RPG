class_name CameraMovement
extends Camera2D

@export var camera_speed: float = 250.0
@onready var player: Player = $"../Player"

const CAMERA_MOVE_BOUNDARY: float = 100.0
const MIN_ZOOM: Vector2 = Vector2(.5, .5)
const MAX_ZOOM: Vector2 = Vector2(8, 8)

var mouse_in_window: bool = false
var is_movement_enabled: bool = true

func _process(delta: float) -> void:
	if !mouse_in_window:
		return
	
	if is_movement_enabled:
		_process_camera_movement(delta)

func _input(event):
	if is_movement_enabled && event.is_action_pressed("CAMERA_ZOOM_IN"):
		_set_zoom(self.zoom * Vector2(1.25, 1.25))
	elif is_movement_enabled && event.is_action_pressed("CAMERA_ZOOM_OUT"):
		_set_zoom(self.zoom * Vector2(.75, .75))
	elif is_movement_enabled && event.is_action_pressed("TRACK_PLAYER"):
		self.position = player.position

func _set_zoom(desired_zoom: Vector2):
	if desired_zoom > MAX_ZOOM:
		self.zoom = MAX_ZOOM
	elif desired_zoom < MIN_ZOOM:
		self.zoom = MIN_ZOOM
	else:
		self.zoom = desired_zoom

func _process_camera_movement(delta: float) -> void:
	var viewport: Viewport = get_viewport()
	var mouse_pos: Vector2 = viewport.get_mouse_position()
	if mouse_pos.x > viewport.size.x - CAMERA_MOVE_BOUNDARY:
		self.position.x += camera_speed * delta
	elif mouse_pos.x < CAMERA_MOVE_BOUNDARY:
		self.position.x -= camera_speed * delta
	if mouse_pos.y > viewport.size.y - CAMERA_MOVE_BOUNDARY:
		self.position.y += camera_speed * delta
	if mouse_pos.y < CAMERA_MOVE_BOUNDARY:
		self.position.y -= camera_speed * delta

func _notification(event):
	match event:
		NOTIFICATION_WM_MOUSE_EXIT:
			mouse_in_window = false
		NOTIFICATION_WM_MOUSE_ENTER:
			mouse_in_window = true
