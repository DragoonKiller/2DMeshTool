extends Camera2D

var zoom_speed = 0.05
var min_zoom = 0.1
var max_zoom = 3.0
var is_dragging = false
var drag_origin = Vector2.ZERO

func _unhandled_input(event):
	if event is InputEventMouseButton and (event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN):
		var mouse_pos_before = get_local_mouse_position()

		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom *= 1 + zoom_speed
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom /= 1 + zoom_speed

		zoom.x = clamp(zoom.x, min_zoom, max_zoom)
		zoom.y = clamp(zoom.y, min_zoom, max_zoom)

		var mouse_pos_after = get_local_mouse_position()
		var _offset = mouse_pos_before - mouse_pos_after
		position += _offset

	# drag
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			is_dragging = event.pressed
			if is_dragging:
				drag_origin = event.position
	elif event is InputEventMouseMotion and is_dragging:
		var delta = event.position - drag_origin
		position -= delta / zoom
		drag_origin = event.position
