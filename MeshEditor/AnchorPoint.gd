extends Node2D

const Dot = preload("res://MeshEditor/Dot.gd")

@export
var component_name :String

@export
var type_name :String = ""

@export
var selected :bool

@export
var poly :Array[Dot] = []


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
		if Utils.show_id_for_anchors:
			draw_string(Utils.font_default, Vector2.UP * 10, component_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 20)
		var poly_positions = PackedVector2Array(poly.map(func(x:Dot): return x.position - position))
		var poly_color :Color = Color.RED
		poly_color.a = 0.2
		var colors = PackedColorArray([poly_color])
		draw_polygon(poly_positions, colors)


func show_poly(poly_to_show:Array[Dot]):
	self.poly = poly_to_show
