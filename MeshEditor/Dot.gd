extends Node2D

@export
var selected : bool = false

func _process(delta:float) -> void:
	pass

func _draw() -> void:
	if selected:
		draw_circle(Vector2.ZERO, 5, Color.CORNFLOWER_BLUE, true)
	else:
		draw_circle(Vector2.ZERO, 5, Color.ANTIQUE_WHITE, true)
		
	
