extends Node2D

const Dot = preload("res://MeshEditor/Dot.gd")

@export
var from :int = -1
@export
var to :int = -1
@export
var dotArray :Array[Dot] = []

func get_from():
	return dotArray[from]

func get_to():
	return dotArray[to]

func _process(_delta:float):
	queue_redraw()

func _draw():
	if not (0 <= from and from <= dotArray.size()):
		return
	if not (0 <= to and to <= dotArray.size()):
		return
		
	var fromDot = dotArray[from]
	var toDot = dotArray[to]
	var selected = fromDot.selected and toDot.selected
	var fromPos = fromDot.position
	var toPos = toDot.position
	if selected:
		draw_line(fromPos, toPos, Color.SANDY_BROWN, -2)
	else:
		draw_line(fromPos, toPos, Color.DARK_BLUE, -2)
	
