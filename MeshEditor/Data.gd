extends Node

const Dot = preload("res://MeshEditor/Dot.gd")
const Segment = preload("res://MeshEditor/Segment.gd")
const AnchorPoint = preload("res://MeshEditor/AnchorPoint.gd")

const file_path = "user://data.txt"

@export
var dots :Array[Dot] = []

@export
var segments :Array[Segment] = []

@export
var anchors :Array[AnchorPoint] = []

@export
var root:Node

func _get_backup_number(file_name: String, base_name: String) -> int:
	if file_name.begins_with(base_name + ".") and file_name.ends_with(".back"):
		var number_str = file_name.trim_prefix(base_name + ".").trim_suffix(".back")
		return int(number_str)
	return -1

func _get_all_backup_numbers(base_path: String) -> Array:
	var dir := DirAccess.open("user://")
	if dir == null:
		return []

	var base_name := base_path.get_file()
	var numbers := []

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		var num := _get_backup_number(file_name, base_name)
		if num >= 0:
			numbers.append({"file": file_name, "num": num})
		file_name = dir.get_next()
	dir.list_dir_end()

	numbers.sort_custom(func(a, b): return a.num < b.num)

	return numbers

func find_latest_backup_file(base_path: String) -> String:
	var backups = _get_all_backup_numbers(base_path)
	if backups.is_empty():
		return ""
	
	var max_num = backups[0]
	for entry in backups:
		if entry.num > max_num.num:
			max_num = entry

	return "user://" + max_num.file

func find_next_backup_file(base_path: String) -> String:
	var backups := _get_all_backup_numbers(base_path)
	var next_num := 0
	for entry in backups:
		if entry.num >= next_num:
			next_num = entry.num + 1

	var base_name := base_path.get_file()
	return "user://%s.%d.back" % [base_name, next_num]

func serialize_core(file: ConfigFile, use_placeholder:bool):
	if use_placeholder:
		file.set_value("Dots", "_", "_")
	for i in dots.size():
		file.set_value("Dots", String.num_int64(i), dots[i].position)
	
	if use_placeholder:
		file.set_value("Segments", "_", "_")
	for i in segments.size():
		var from: int = segments[i].from
		var to: int = segments[i].to
		file.set_value("Segments", String.num_int64(i), Vector2i(from, to))
		
	if use_placeholder:
		file.set_value("Anchors", "_", "_")
	for i in anchors.size():
		file.set_value("Anchors", anchors[i].component_name, anchors[i].position)

func serialize():
	print("serialize!")
	var file = ConfigFile.new()
	serialize_core(file, true)

	if FileAccess.file_exists(file_path):
		Utils.copy_external_file(file_path, file_path + ".back")
	
	var backup_path = find_next_backup_file(file_path)
	print("backup! [", file_path, "] => [", backup_path, "]")
	Utils.copy_external_file(file_path, backup_path)
	
	var ok = file.save(file_path)
	if ok != OK:
		print("save error!", ok)
	print("save to [" + ProjectSettings.globalize_path(file_path) + "]")


func serialize_to_destination(pathOrigin: String):
	print("serialize to destination!")
	var basename = pathOrigin.get_basename()
	var path = basename + ".txt"
	var file = ConfigFile.new()
	serialize_core(file, false)

	var ok = file.save(path)
	if ok != OK:
		print("save error!", ok)
	print("save to [" + ProjectSettings.globalize_path(path) + "]")

func deserialize_backup(n :int):
	var found = _get_all_backup_numbers("user://data.txt")
	if found.size() <= n:
		print('no backup can be taken!')
		return
	deserialize("user://" + found[-n].file)
	

func deserialize(path = file_path):
	print("deserialize!")
	print("read from [" + ProjectSettings.globalize_path(path) + "]")
	#load from data.txt
	var file = ConfigFile.new()
	var ok = file.load(path)
	if ok != OK:
		return # keep default data.
	
	for dot in dots:
		dot.queue_free()
	for seg in segments:
		seg.queue_free()
	dots.clear()
	segments.clear()
	
	var dotsKeys = file.get_section_keys("Dots")
	for dotKey in dotsKeys:
		if dotKey == "_":
			continue
		var i = int(dotKey)
		var value :Vector2 = file.get_value("Dots", dotKey)
		assert(i == dots.size())
		new_dot(value)
	
	var segKeys = file.get_section_keys("Segments")
	for segKey in segKeys:
		if segKey == "_":
			continue
		var value :Vector2i = file.get_value("Segments", segKey)
		if not (0 <= value.x and value.x < dots.size()):
			continue
		if not (0 <= value.y and value.y < dots.size()):
			continue
		new_segment(value.x, value.y)
		
	var anchorKeys = file.get_section_keys("Anchors")
	for anchorKey in anchorKeys:
		if anchorKey == "_":
			continue
		var value :Vector2 = file.get_value("Anchors", anchorKey)
		new_anchor(value, anchorKey)


func new_dot(position:Vector2) -> Dot:
	var dot = Dot.new()
	dot.name = String.num_uint64(dots.size())
	dot.position = position
	dots.append(dot)
	root.add_child(dot)
	return dot

func new_segment(from:int, to:int) -> Segment:
	var segment = Segment.new()
	segment.from = from
	segment.to = to
	segment.dotArray = dots
	segment.name = String.num_int64(segments.size())
	segments.append(segment)
	root.add_child(segment)
	return segment

func new_segment_from_dots(from:Dot, to:Dot) -> Segment:
	var fromIndex = dots.find(from)
	var toIndex = dots.find(to)
	if fromIndex < 0:
		return
	if toIndex < 0:
		return
	return new_segment(fromIndex, toIndex)
	
func new_anchor(position:Vector2, anchor_name:String = "") -> AnchorPoint:
	if anchor_name == null or anchor_name == "":
		print('invalid name!')
		return
	var anchor = AnchorPoint.new()
	anchor.position = position
	anchor.name = anchor_name
	anchor.component_name = anchor_name
	print('anchor name:', anchor_name)
	anchors.append(anchor)
	root.add_child(anchor)
	return anchor
	
