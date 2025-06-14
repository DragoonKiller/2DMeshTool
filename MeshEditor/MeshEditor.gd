extends Node2D

const Dot = preload("res://MeshEditor/Dot.gd")
const Segment = preload("res://MeshEditor/Segment.gd")

"""
shortcuts:
	tab: change mode
	
modes:
	move: controlling the move.
	select: select points.
"""

enum Mode {
	Move,
	Select,
}

@export
var mode :Mode = Mode.Move

@export
var selectFrom :Vector2 = Vector2.ZERO

@export
var selectTo :Vector2 = Vector2.ZERO

@export
var updateSelection :bool = false

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
	
	if event.is_action_pressed("ChangeMode"):
		if mode == Mode.Move:
			mode = Mode.Select
		else:
			mode = Mode.Move
	
	if event.is_action_pressed("Delete"):
		delete_selection()
	
	if event.is_action_pressed("AddDot"):
		add_dot()
	
	if event.is_action_pressed("Link"):
		try_link()
	
	if event.is_action_pressed("CancelSelection"):
		clear_selection()
	
	if event.is_action_pressed("Selection"):
		selectFrom = get_global_mouse_position()
		selectTo = selectFrom
		updateSelection = true
		if not Input.is_key_pressed(KEY_SHIFT):
			clear_selection()
	
	if updateSelection and (event is InputEventMouseMotion):
		selectTo = get_global_mouse_position()
	
	if event.is_action_released("Selection"):
		selectTo = selectFrom
		updateSelection = false

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		serialize()

func _process(_dt: float) -> void:
	
	if updateSelection:
		var rect = get_selection_rect()
		for dot in dots:
			if rect.has_point(dot.position):
				dot.selected = true
	
	queue_redraw()

func _draw():
	if updateSelection:
		var rect = get_selection_rect()
		var color = Color(1, 1, 1, 0.1)
		draw_rect(rect, color, true)
		color.a = 0.4
		draw_rect(rect, color, false, 2)

func clear_selection():
	for dot in dots:
		dot.selected = false

func add_dot():
	print('add dot!')
	var dot = Dot.new()
	dot.position = get_global_mouse_position()
	dots.append(dot)
	dot.name = String.num(dots.size() - 1)
	add_child(dot)

func try_link():
	print('try link')
	var selected = selected_dots()
	print(selected, ' ', dots.size(), ' ', selected.size())
	if selected.size() != 2:
		return
	for seg in segments:
		var dot1 = seg.get_from()
		var dot2 = seg.get_to()
		if (dot1 == selected[0] and dot2 == selected[1]) or (dot1 == selected[0] and dot2 == selected[1]):
			print('already linked')
			return   # already linked
	# not linked
	print('link!')
	var seg = Segment.new()
	seg.from = dots.find(selected[0])
	seg.to = dots.find(selected[1])
	seg.dotArray = dots
	segments.append(seg)
	add_child(seg)

func selected_dots() -> Array[Dot]:
	return dots.filter(func(x:Dot): return x.selected)

func get_selection_rect():
	var from = selectFrom.min(selectTo)
	var to = selectFrom.max(selectTo)
	var rect = Rect2(from, to - from)
	return rect

func delete_selection():
	var remove_segments = segments.filter(func(x:Segment): return x.get_from().selected or x.get_to().selected)
	for seg :Segment in remove_segments:
		seg.queue_free()
	segments = segments.filter(func(x:Segment): return not (x.get_from().selected or x.get_to().selected))
	
	var to_be_removed = dots.filter(func(x:Dot): return x.selected)
	for dot :Dot in to_be_removed:
		dot.queue_free()
	dots = dots.filter(func(x:Dot): return not x.selected)

const file_path = "user://data.txt"

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
	
	var ok = file.save(file_path)
	if ok != OK:
		print("save error!", ok)
	
	print("save to [" + ProjectSettings.globalize_path(file_path) + "]")

func deserialize():
	print("deserialize!")
	print("read from [" + ProjectSettings.globalize_path(file_path) + "]")
	#load from data.txt
	var file = ConfigFile.new()
	var ok = file.load(file_path)
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
		dot.name = String.num_int64(i)
		dot.position = value
		dots.append(dot)
		add_child(dot)
	
	var segKeys = file.get_section_keys("Segments")
	for segKey in segKeys:
		if segKey == "_":
			continue
		var value :Vector2i = file.get_value("Segments", segKey)
		var segment = Segment.new()
		if not (0 <= value.x and value.x < dots.size()):
			continue
		if not (0 <= value.y and value.y < dots.size()):
			continue
		segment.from = value.x
		segment.to = value.y
		segment.dotArray = dots
		segments.append(segment)
		add_child(segment)
