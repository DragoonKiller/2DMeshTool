extends Node2D

@export
var component_name :String

@export
var selected :bool

const selected_color := Color(1, 1, 1, 1)
const non_selected_color := Color(0.8, 0.6, 0.5, 1)

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var color :Color
	if selected:
		color = selected_color
	else:
		color = non_selected_color
	
	Utils.draw_centered_rect(self, Vector2.ZERO, Vector2(10, 2), color, true)
	Utils.draw_centered_rect(self, Vector2.ZERO, Vector2(2, 10), color, true)
	draw_circle(Vector2.ZERO, 4, color, true)
	if selected:
		draw_string(Utils.font_default, Vector2.UP * 10, name, HORIZONTAL_ALIGNMENT_LEFT, -1, 20)
