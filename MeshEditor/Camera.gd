extends Camera2D

var zoom_speed := 0.05
var min_zoom := 0.5
var max_zoom := 2.0

func _unhandled_input(event):
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_UP:
        zoom *= 1 + zoom_speed
    elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
        zoom /= 1 + zoom_speed

    zoom.x = clamp(zoom.x, min_zoom, max_zoom)
    zoom.y = clamp(zoom.y, min_zoom, max_zoom)
    