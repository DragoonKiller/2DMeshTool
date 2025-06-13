extends Node2D

const Dot = preload("res://MeshEditor/Dot.gd")
const Segment = preload("res://MeshEditor/Segment.gd")


@export
var dots :Array[Dot] = []

@export
var segments :Array[Segment] = []

@export
var selectedDotsIndex :Array[int] = []

@export
var selectedSegmentsIndex :Array[int] = []

func _ready() -> void:
	deserialize()

func _exit_tree() -> void:
	serialize()

func _input(event):
	if (event is InputEventKey) and event.pressed:
		var keyEvent = event as InputEventKey
		if keyEvent.keycode == KEY_A:
			print('AA')

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		serialize()

func serialize():
	print("serialize!")
	# save to data.txt
	var file = ConfigFile.new()
	
	file.set_value("Dots", "_", "_")
	
	for i in dots.size():
		file.set_value("Dots", String.num(i), dots[i].position)
	
	file.set_value("Segments", "_", "_")
	
	for i in segments.size():
		var from :int = segments[i].from
		var to :int = segments[i].to
		file.set_value("Segments", String.num(i), Vector2i(from, to))
	
	var ok = file.save("user://data.txt")
	if ok != OK:
		print("save error!", ok)
	
	print("save to [" + OS.get_data_dir() + "] => data.txt")

func deserialize():
	print("deserialize!")
	print("read from [" + OS.get_data_dir() + "] => data.txt")
	#load from data.txt
	var file = ConfigFile.new()
	var ok = file.load("user://data.txt")
	if ok != OK:
		return # keep default data.
	
	var dotsKeys = file.get_section_keys("Dots")
	for dotKey in dotsKeys:
		if dotKey == "_":
			continue
		var i = int(dotKey)
		var value :Vector2 = file.get_value("Dots", dotKey)
		assert(i == dots.size())
		var dot = Dot.new()
		dot.position = value
		dots.append(dot)
	
	var segKeys = file.get_section_keys("Segments")
	for segKey in segKeys:
		if segKey == "_":
			continue
		var i = int(segKey)
		var value :Vector2i = file.get_value("Segments", segKey)
		assert(i == segments.size())
		var segment = Segment.new()
		segment.from = value.x
		segment.to = value.y
		segments.append(segment)
