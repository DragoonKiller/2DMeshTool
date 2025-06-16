extends Node2D

const Dot = preload("res://MeshEditor/Dot.gd")
const Segment = preload("res://MeshEditor/Segment.gd")
const AnchorPoint = preload("res://MeshEditor/AnchorPoint.gd")
const SpriteDisplay = preload("res://MeshEditor/SpriteDisplay.gd")
const Data = preload("res://MeshEditor/Data.gd")

@export
var dragFrom :Vector2 = Vector2.ZERO

@export
var dragTo :Vector2 = Vector2.ZERO

@export
var updateSelection :bool = false

@export
var updateMove :bool = false

@export
var dotsPositionCopy :Array[Vector2] = []

@export
var anchorsPositionCopy :Array[Vector2] = []

@export
var selectedDotsIndex :Array[int] = []

@export
var selectedSegmentsIndex :Array[int] = []

@export
var undo_times :int = 0

@export
var data:Data

func _ready() -> void:
	data.deserialize()

func _exit_tree() -> void:
	data.serialize()

func _unhandled_input(event: InputEvent) -> void:
	
	if event.is_action_pressed("Delete"):
		data.delete_selection()
		get_viewport().set_input_as_handled()
	
	if event.is_action_pressed("AddDot") and not event.is_action_pressed("AddDotLinked"):
		data.new_dot(get_global_mouse_position())
		record_do()
		get_viewport().set_input_as_handled()
		
	if event.is_action_pressed("AddDotLinked"):
		add_dot_linked()
		record_do()
		get_viewport().set_input_as_handled()
	
	if event.is_action_pressed("Link"):
		try_link()
		record_do()
		get_viewport().set_input_as_handled()
	
	if event.is_action_pressed("CancelSelection"):
		clear_selection()
		get_viewport().set_input_as_handled()
	
	if event.is_action_pressed("Undo"):
		undo()
		get_viewport().set_input_as_handled()
	
	if event.is_action_pressed("AlignHorizontal"):
		align_horizontal()
		record_do()
		get_viewport().set_input_as_handled()
	
	if event.is_action_pressed("AlignVertical"):
		align_vertical()
		record_do()
		get_viewport().set_input_as_handled()
	
	if event.is_action_pressed("DeleteEdge"):
		delete_edge()
		record_do()
		get_viewport().set_input_as_handled()
	
	if event.is_action_pressed("Split"):
		split()
		record_do()
		get_viewport().set_input_as_handled()
		
	if event.is_action_pressed("MirrorHorizontal"):
		mirror_horizontal()
		record_do()
		get_viewport().set_input_as_handled()
	
	if event.is_action_pressed("MirrorVertical"):
		mirror_vertical()
		record_do()
		get_viewport().set_input_as_handled()
	
	if event.is_action_pressed("AddAnchor"):
		data.new_anchor(get_global_mouse_position(), "NewAnchor")
		record_do()
	
	if event.is_action_pressed("Save"):
		data.serialize()
	
	if event.is_action_pressed("SaveToDestination"):
		var path :String = (get_parent().find_child("SpriteDisplay") as SpriteDisplay).image_path
		
		if not (path == null or path == ""):
			data.serialize_to_destination(path)
			
		get_viewport().set_input_as_handled()
	
	if event.is_action_pressed("Selection"):
		dragFrom = get_global_mouse_position()
		dragTo = dragFrom
		if Input.is_key_pressed(KEY_SPACE):
			updateMove = true
			dotsPositionCopy.assign(data.dots.map(func(x): return x.position))
			anchorsPositionCopy.assign(data.anchors.map(func(x): return x.position))
		else:
			if not Input.is_key_pressed(KEY_SHIFT):
				clear_selection()
			updateSelection = true
		get_viewport().set_input_as_handled()
	
	if event is InputEventMouseMotion:
		dragTo = get_global_mouse_position()
		get_viewport().set_input_as_handled()
	
	if event.is_action_released("Selection"):
		dragTo = dragFrom
		if updateMove:
			record_do()
		updateMove = false
		updateSelection = false
		get_viewport().set_input_as_handled()
		
	

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		data.serialize()

func _process(_dt: float) -> void:
	
	if updateSelection:
		if not Input.is_key_pressed(KEY_SHIFT):
			clear_selection()
		update_selection()
	
	if updateMove:
		print(dragTo - dragFrom)
		for i in data.dots.size():
			if data.dots[i].selected:
				data.dots[i].position = dotsPositionCopy[i] + (dragTo - dragFrom)
		for i in data.anchors.size():
			if data.anchors[i].selected:
				data.anchors[i].position = anchorsPositionCopy[i] + (dragTo - dragFrom)
	
	queue_redraw()

func _draw():
	if updateSelection:
		var rect = get_selection_rect()
		var color = Color(1, 1, 1, 0.1)
		draw_rect(rect, color, true)
		color.a = 0.4
		draw_rect(rect, color, false, 2)
	
	_draw_op_hints()

func clear_selection():
	for dot in data.dots:
		dot.selected = false
	for anchor in data.anchors:
		anchor.selected = false

func update_selection():
	var rect = get_selection_rect()
	for dot in data.dots:
		if rect.has_point(dot.position):
			dot.selected = true
	for anchor in data.anchors:
		if rect.has_point(anchor.position):
			anchor.selected = true

func add_dot_linked():
	print('add dot linked!')
	var dot = data.new_dot(get_global_mouse_position())
	var selected = get_selected_dots()
	if selected.size() != 1:
		return
	var prevSelected = selected[0]
	prevSelected.selected = true
	dot.selected = true
	try_link()
	prevSelected.selected = false
	return dot

func try_link():
	print('try link')
	var selected := get_selected_dots()
	print(selected, ' ', data.dots.size(), ' ', selected.size())
	if selected.size() != 2:
		return
	for seg in data.segments:
		var dot1 = seg.from
		var dot2 = seg.to
		if (dot1 == selected[0] and dot2 == selected[1]) or (dot1 == selected[0] and dot2 == selected[1]):
			print('already linked')
			return   # already linked
	# not linked
	print('link!')
	return data.new_segment(selected[0], selected[1])

func get_selected_dots() -> Array[Dot]:
	return data.dots.filter(func(x:Dot): return x.selected)

func get_selection_rect():
	var from = dragFrom.min(dragTo)
	var to = dragFrom.max(dragTo)
	var rect = Rect2(from, to - from)
	return rect

func record_do():
	undo_times = 0
	data.serialize()

func undo():
	undo_times += 1
	data.deserialize_backup(undo_times)

func _center_of_selected_nodes():
	var center = Vector2.ZERO
	var count = 0
	for dot in data.dots:
		if dot.selected:
			center = center + dot.position
			count += 1
	center /= count
	return center

func align_horizontal():
	var center = _center_of_selected_nodes()
	for dot in data.dots:
		if dot.selected:
			var pos = dot.position
			pos.y = center.y
			dot.position = pos

func align_vertical():
	var center = _center_of_selected_nodes()
	for dot in data.dots:
		if dot.selected:
			var pos = dot.position
			pos.x = center.x
			dot.position = pos

func delete_edge():
	var to_be_removed = { }
	for seg in data.segments:
		var from = seg.get_from()
		var to = seg.get_to()
		if from.selected and to.selected:
			to_be_removed[seg] = 0
			seg.queue_free()
	data.segments = data.segments.filter(func(seg:Segment): return not to_be_removed.has(seg))

func split():
	var selected = get_selected_dots()
	if selected.size() != 2:
		return
	
	var selectedSegments :Array[Segment] = []
	selectedSegments.assign(data.segments.filter(func(seg:Segment): return selected.has(seg.get_from()) and selected.has(seg.get_to())))
	if selectedSegments.size() == 0:
		return
	
	for splitSeg in selectedSegments:
		var a := splitSeg.from
		var b := splitSeg.to
		
		# new node
		var new_dot_position = (a.position + b.position) / 2
		var c := data.new_dot(new_dot_position)
		
		# split segment [a -> b] change to [a -> c]
		splitSeg.to = c
		print(splitSeg.from, splitSeg.to)
		
		# new segment [b -> c]
		data.new_segment(b, c)
	
func mirror_horizontal():
	for dot in data.dots:
		var p = dot.position
		p.x = -p.x
		dot.position = p

func mirror_vertical():
	for dot in data.dots:
		var p = dot.position
		p.y = -p.y
		dot.position = p
		
const actions := [
	"Delete",
	"AddDot",
	"AddDotLinked",
	"Link",
	"CancelSelection",
	"Undo",
	"AlignHorizontal",
	"AlignVertical",
	"DeleteEdge",
	"Split",
	"MirrorHorizontal",
	"MirrorVertical",
	"Save",
	"Selection",
	"SaveToDestination",
	"AddAnchor",
]

func _draw_op_hints():
	var base_pos = Utils.screen_bottom_left + Vector2.UP * 10 * Utils.camera_zoom_scale
	var line_height = 16 * Utils.camera_zoom_scale
	draw_set_transform(Vector2.ZERO, 0, Vector2.ONE * Utils.camera_zoom_scale)
	for i in actions.size():
		var action = actions[i]
		var pos = base_pos + Vector2.UP * line_height * i
		var keys = Utils.get_keys_for_action(action)
		var keyStrings = ", ".join(keys)
		var text = "%s: %s" % [action, keyStrings]
		draw_string(Utils.font_default, pos / Utils.camera_zoom_scale, text, HORIZONTAL_ALIGNMENT_LEFT)
