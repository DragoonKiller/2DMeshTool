extends Node2D

@export
var _selected :bool = false

const selectColor = Color(0.9, 0.6, 0.4, 1)
const nonSelectColor = Color(0.8, 0.7, 0.2, 0.7)

var selected:
	get:
		return _selected
	set(value):
		_selected = value
		queue_redraw()

func _process(_delta:float) -> void:
	queue_redraw()

func _draw() -> void:
	
	if _selected:
		draw_circle(Vector2.ZERO, 3 * Utils.camera_zoom_scale, selectColor, true)
		draw_set_transform(Vector2.ZERO, rotation, scale * min(0.5, Utils.camera_zoom_scale))
		if Utils.show_id_for_dots:
			draw_string(Utils.font_default, Vector2.UP * 10, self.name, HORIZONTAL_ALIGNMENT_LEFT, -1, 24)
		draw_set_transform(Vector2.ZERO, rotation, scale)
	else:
		draw_circle(Vector2.ZERO, 3 * Utils.camera_zoom_scale, nonSelectColor, true)
		
	
