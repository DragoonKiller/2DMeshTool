extends Node2D

const Dot = preload("res://MeshEditor/Dot.gd")

@export
var selected :bool = false
@export
var from :int = -1
@export
var to :int = -1
@export
var dotArray :Array[Dot] = []


func _process(delta:float):
	pass

func _draw():
	if not (0 <= from and from <= dotArray.size()):
		return
	if not (0 <= to and to <= dotArray.size()):
		return
		
	var fromPos = dotArray[from]
	var toPos = dotArray[to]
	if selected:
		draw_line(fromPos, toPos, Color.SANDY_BROWN, 1.5)
	else:
		draw_line(fromPos, toPos, Color.DARK_BLUE, 2.5, true)
	
