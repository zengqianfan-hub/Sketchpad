extends Camera2D

@export var max_zoom: float = 30.0
@export var min_zoom: float = 0.1

@export var zoom_speed: float = 1.1
@export var drag_speed: float = 1.0

var movable: bool = false
var is_dragging: bool = false

var touch_points: Dictionary = {}
var start_distance: float = 0.0
var start_zoom: Vector2 = Vector2.ONE
var last_touch_center: Vector2 = Vector2.ZERO


func _input(event: InputEvent) -> void:
	if not movable:
		return

	if event is InputEventScreenTouch:
		if event.pressed:
			touch_points[event.index] = event.position
		else:
			touch_points.erase(event.index)
		
		if touch_points.size() == 2:
			var points = touch_points.values()
			start_distance = points[0].distance_to(points[1])
			start_zoom = zoom
			last_touch_center = (points[0] + points[1]) / 2.0
		else:
			start_distance = 0.0

	elif event is InputEventScreenDrag:
		touch_points[event.index] = event.position

		if touch_points.size() == 2:
			var points = touch_points.values()
			var p1: Vector2 = points[0]
			var p2: Vector2 = points[1]
			
			var current_distance: float = p1.distance_to(p2)
			
			if start_distance <= 0.0:
				start_distance = current_distance
				start_zoom = zoom
				last_touch_center = (p1 + p2) / 2.0

			if start_distance > 0.001:
				var zoom_factor: float = current_distance / start_distance
				var target_zoom: Vector2 = start_zoom * zoom_factor
				zoom.x = clamp(target_zoom.x, min_zoom, max_zoom)
				zoom.y = clamp(target_zoom.y, min_zoom, max_zoom)

			var current_center: Vector2 = (p1 + p2) / 2.0
			var center_delta: Vector2 = current_center - last_touch_center
			var drag_diff: Vector2 = (center_delta / zoom) * drag_speed
			position -= drag_diff
			last_touch_center = current_center

	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			is_dragging = event.pressed
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom(1.0 / zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom(zoom_speed)

	elif event is InputEventMouseMotion:
		if is_dragging:
			var drag_diff = (event.relative / zoom) * drag_speed
			position -= drag_diff


func _zoom(factor: float) -> void:
	zoom *= factor
	zoom.x = clamp(zoom.x, min_zoom, max_zoom)
	zoom.y = clamp(zoom.y, min_zoom, max_zoom)
