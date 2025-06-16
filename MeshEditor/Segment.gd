extends Node2D

const Dot = preload("res://MeshEditor/Dot.gd")

@export
var from :Dot = null
@export
var to :Dot = null
@export
var dotArray :Array[Dot] = []

const selectColor = Color(0.9, 0.6, 0.4, 0.8)
const nonSelectColor = Color(0.8, 0.7, 0.2, 1)

func _process(_delta:float):
	queue_redraw()

func _draw():
	var selected = from.selected and to.selected
	var fromPos = from.position
	var toPos = to.position
	if selected:
		draw_line(fromPos, toPos, selectColor, 2 * Utils.camera_zoom_scale)
	else:
		draw_line(fromPos, toPos, nonSelectColor, 2 * Utils.camera_zoom_scale)
	
