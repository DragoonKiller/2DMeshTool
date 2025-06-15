extends Node2D

const Dot = preload("res://MeshEditor/Dot.gd")

@export
var from :int = -1
@export
var to :int = -1
@export
var dotArray :Array[Dot] = []

const selectColor = Color(0.9, 0.6, 0.4, 0.8)
const nonSelectColor = Color(0.8, 0.7, 0.2, 1)

func get_from():
	return dotArray[from]

func get_to():
	return dotArray[to]

func _process(_delta:float):
	queue_redraw()

func _draw():
	if not (0 <= from and from < dotArray.size()):
		return
	if not (0 <= to and to < dotArray.size()):
		return
		
	var fromDot = dotArray[from]
	var toDot = dotArray[to]
	var selected = fromDot.selected and toDot.selected
	var fromPos = fromDot.position
	var toPos = toDot.position
	if selected:
		draw_line(fromPos, toPos, selectColor, 2 * Utils.camera_zoom_scale)
	else:
		draw_line(fromPos, toPos, nonSelectColor, 2 * Utils.camera_zoom_scale)
	
