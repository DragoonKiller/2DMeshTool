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

static var default_font :Font

func _draw() -> void:
	
	if not default_font:
		# Accessing the default font in code
		var label = Label.new()
		default_font = label.get_theme_font("") # Gets the default font used by the label
		label.free()
	
	if _selected:
		draw_circle(Vector2.ZERO, 5, Color.CORNFLOWER_BLUE, true)
		draw_string(default_font, Vector2.UP * 10, self.name)
	else:
		draw_circle(Vector2.ZERO, 5, Color.ANTIQUE_WHITE, true)
		
	
