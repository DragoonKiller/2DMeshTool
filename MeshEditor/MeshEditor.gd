extends Node2D

const Dot = preload("res://MeshEditor/Dot.gd")
const Segment = preload("res://MeshEditor/Segment.gd")

@export
var dragFrom :Vector2 = Vector2.ZERO

@export
var dragTo :Vector2 = Vector2.ZERO

@export
var updateSelection :bool = false

@export
var updateMove :bool = false

@export
var positionCopy :Array[Vector2] = []

@export
var dots :Array[Dot] = []

@export
var segments :Array[Segment] = []

@export
var selectedDotsIndex :Array[int] = []

@export
var selectedSegmentsIndex :Array[int] = []

@export
var undo_times :int = 0

func _ready() -> void:
	DataSave.deserialize(self, dots, segments)

func _exit_tree() -> void:
	DataSave.serialize(dots, segments)

func _input(event):
	
	if event.is_action_pressed("Delete"):
		delete_selection()
	
	if event.is_action_pressed("AddDot") and not event.is_action_pressed("AddDotLinked"):
		add_dot()
		
	if event.is_action_pressed("AddDotLinked"):
		add_dot_linked()
	
	if event.is_action_pressed("Link"):
		try_link()
	
	if event.is_action_pressed("CancelSelection"):
		clear_selection()
	
	if event.is_action_pressed("Undo"):
		undo()
	
	if event.is_action_pressed("AlignHorizontal"):
		align_horizontal()
	
	if event.is_action_pressed("AlignVertical"):
		align_vertical()
	
	if event.is_action_pressed("Selection"):
		dragFrom = get_global_mouse_position()
		dragTo = dragFrom
		if Input.is_key_pressed(KEY_SPACE):
			updateMove = true
			positionCopy.assign(dots.map(func(x): return x.position))
		else:
			if not Input.is_key_pressed(KEY_SHIFT):
				clear_selection()
			updateSelection = true
	
	if event is InputEventMouseMotion:
		dragTo = get_global_mouse_position()
	
	if event.is_action_released("Selection"):
		dragTo = dragFrom
		if updateMove:
			record_do()
		updateMove = false
		updateSelection = false

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		DataSave.serialize(dots, segments)

func _process(_dt: float) -> void:
	
	if updateSelection:
		if not Input.is_key_pressed(KEY_SHIFT):
			clear_selection()
		var rect = get_selection_rect()
		for dot in dots:
			if rect.has_point(dot.position):
				dot.selected = true
	
	if updateMove:
		print(dragTo - dragFrom)
		for i in range(dots.size()):
			if dots[i].selected:
				dots[i].position = positionCopy[i] + (dragTo - dragFrom)
	
	queue_redraw()

func _draw():
	if updateSelection:
		var rect = get_selection_rect()
		var color = Color(1, 1, 1, 0.1)
		draw_rect(rect, color, true)
		color.a = 0.4
		draw_rect(rect, color, false, 2)
	
	var info = ""
	if updateMove:
		info = "Move"
	elif updateSelection:
		info = "Select"
	draw_string(Utils.font_default, Utils.screen_bottom_left + Vector2.UP * 10, info, HORIZONTAL_ALIGNMENT_LEFT)

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
	record_do()

func add_dot_linked():
	print('add dot linked!')
	add_dot()
	var new_dot = dots[-1]
	var selected = selected_dots()
	if selected.size() != 1:
		return
	var prevSelected = selected[0]
	prevSelected.selected = true
	new_dot.selected = true
	try_link()
	prevSelected.selected = false
	record_do()

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
	record_do()

func selected_dots() -> Array[Dot]:
	return dots.filter(func(x:Dot): return x.selected)

func get_selection_rect():
	var from = dragFrom.min(dragTo)
	var to = dragFrom.max(dragTo)
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


func record_do():
	undo_times = 0
	DataSave.serialize(dots, segments)

func undo():
	undo_times += 1
	DataSave.deserialize_backup(self, dots, segments, undo_times)

func _center_of_selected_nodes():
	var center = Vector2.ZERO
	var count = 0
	for dot in dots:
		if dot.selected:
			center = center + dot.position
			count += 1
	center /= count
	return center

func align_horizontal():
	var center = _center_of_selected_nodes()
	for dot in dots:
		if dot.selected:
			var pos = dot.position
			pos.y = center.y
			dot.position = pos
	record_do()

func align_vertical():
	var center = _center_of_selected_nodes()
	for dot in dots:
		if dot.selected:
			var pos = dot.position
			pos.x = center.x
			dot.position = pos
	record_do()
