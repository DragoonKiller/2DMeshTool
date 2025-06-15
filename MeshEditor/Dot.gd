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
	pass

func _draw() -> void:
	
	if _selected:
		draw_circle(Vector2.ZERO, 3, selectColor, true)
		draw_string(Utils.font_default, Vector2.UP * 10, self.name)
	else:
		draw_circle(Vector2.ZERO, 3, nonSelectColor, true)
		
	
