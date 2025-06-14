extends Node2D

@export
var _selected :bool = false

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
		draw_circle(Vector2.ZERO, 5, Color.CORNFLOWER_BLUE, true)
	else:
		draw_circle(Vector2.ZERO, 5, Color.ANTIQUE_WHITE, true)
		
	
