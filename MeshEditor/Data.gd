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
		var from = dots.find(segments[i].from)
		var to = dots.find(segments[i].to)
		file.set_value("Segments", String.num_int64(i), Vector2i(from, to))
		
	if use_placeholder:
		file.set_value("Anchors", "_", "_")
	for i in anchors.size():
		file.set_value("Anchors", anchors[i].component_name, anchors[i].position)
		file.set_value("AnchorType", anchors[i].component_name, anchors[i].type_name)
		file.set_value("AnchorGroup", anchors[i].component_name, anchors[i].group_name)

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
	
	for i in dots.size():
		file.set_value("Dots", String.num_int64(i), -dots[i].position)
	
	var polys = compute_polys()
	
	var dot_to_index = { }
	for i in dots.size():
		dot_to_index[dots[i]] = i
	
	for anchor in anchors:
		var indices :String = ""
		var boundary :String = ""
		for i in polys.size():
			var poly :Array[Dot] = polys[i]
			var poly_positions = poly.map(func(x:Dot): return x.position)
			var packed_positions = PackedVector2Array(poly_positions)
			if Geometry2D.is_point_in_polygon(anchor.position, packed_positions):
				boundary = ",".join(poly.map(func(x:Dot): return String.num_int64(dot_to_index[x])))
				var triangles = Geometry2D.triangulate_polygon(packed_positions)
				var s = []
				for j in triangles.size():
					s.append(String.num_int64(dot_to_index[poly[triangles[j]]]))
				indices = ",".join(s)
				break
		file.set_value("Modules", anchor.component_name, indices)
		file.set_value("ModulesBoundaries", anchor.component_name, boundary)
		file.set_value("ModuleType", anchor.component_name, anchor.type_name)
		file.set_value("ModuleGroup", anchor.component_name, anchor.group_name)
		

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
		assert(int(segKey) == segments.size())
		new_segment(dots[value.x], dots[value.y])
		
	var anchorKeys = file.get_section_keys("Anchors")
	for anchorKey in anchorKeys:
		if anchorKey == "_":
			continue
		var value :Vector2 = Vector2.ZERO
		if file.get_value("Anchors", anchorKey) != null:
			value = file.get_value("Anchors", anchorKey)
		var type :String = ""
		if file.get_value("AnchorType", anchorKey) != null:
			type = file.get_value("AnchorType", anchorKey)
		var group :String = ""
		if file.get_value("AnchorGroup", anchorKey) != null:
			group = file.get_value("AnchorGroup", anchorKey)
		new_anchor(value, anchorKey, type, group)


func new_dot(position:Vector2) -> Dot:
	var dot = Dot.new()
	dot.name = String.num_uint64(dots.size())
	dot.position = position
	dots.append(dot)
	root.add_child(dot)
	return dot

func new_segment(from:Dot, to:Dot) -> Segment:
	var segment = Segment.new()
	segment.from = from
	segment.to = to
	segment.name = String.num_uint64(segments.size())
	segments.append(segment)
	root.add_child(segment)
	return segment
	
func new_anchor(position:Vector2, anchor_name:String = "", anchor_type:String = "", anchor_group:String = "") -> AnchorPoint:
	if anchor_name == null or anchor_name == "":
		print('invalid name!')
		return
	var anchor = AnchorPoint.new()
	anchor.position = position
	anchor.name = anchor_name
	anchor.component_name = anchor_name
	anchor.type_name = anchor_type
	anchor.group_name = anchor_group
	# print('anchor name:', anchor_name)
	anchors.append(anchor)
	root.add_child(anchor)
	return anchor

func delete_selection():
	# remove dots.
	var remove_dots = dots.filter(func(x:Dot): return x.selected)
	for dot :Dot in remove_dots:
		dot.queue_free()
	
	# update data array.
	dots = dots.filter(func(x:Dot): return not x.selected)
	
	# remove segments.
	var remove_segments = segments.filter(func(x:Segment): return x.from.selected or x.to.selected)
	for seg :Segment in remove_segments:
		seg.queue_free()
	segments = segments.filter(func(x:Segment): return not (x.from.selected or x.to.selected))
	
	# remove anchors.
	var remove_anchors = anchors.filter(func(x:AnchorPoint): return x.selected)
	for anchor :AnchorPoint in remove_anchors:
		anchor.queue_free()

	anchors = anchors.filter(func(x:AnchorPoint): return not x.selected)


func apply_polys_to_anchors(polys:Array, anchorPolys:Dictionary[String, int]):
	for anchor in anchors:
		anchor.show_poly(polys[anchorPolys[anchor.component_name]])

# compute faces in 2D mesh.
func compute_polys() -> Array:
	# build adjacent map.
	var adjacent_map = { }
	for seg in segments:
		var from = seg.from
		var to = seg.to
		var fromList = adjacent_map.get_or_add(from, [])
		var toList = adjacent_map.get_or_add(to, [])
		fromList.append(to)
		toList.append(from)
	
	var results :Array = []
	
	# find faces. Start with an edge, and go with left-most edge.
	var used = { }
	for dot1 in dots:
		used[dot1] = { }
		for dot2 in dots:
			used[dot1][dot2] = false
	
	for seg in segments:
		if used[seg.from][seg.to]:
			continue
		used[seg.from][seg.to] = true
		used[seg.to][seg.from] = true
		
		var current_path = [seg.from, seg.to]
		var circle1 = compute_circle(current_path[0], current_path[1], adjacent_map)
		var n = circle1.size()
		if n > 2:
			results.append(circle1)
			for i in n:
				used[circle1[i]][circle1[(i + 1) % n]] = true
		var circle2 = compute_circle(current_path[1], current_path[0], adjacent_map)
		n = circle2.size()
		if n > 2:
			results.append(circle2)
			for i in n:
				used[circle2[i]][circle2[(i + 1) % n]] = true
	
	var point_set_for_polys = { }
	for poly :Array[Dot] in results:
		var point_set :Dictionary[Dot, bool] = { }
		for dot in poly:
			point_set[dot] = true
		point_set_for_polys[poly] = point_set
	
	var point_list_for_polys = { }
	for poly :Array[Dot] in results:
		var point_list := PackedVector2Array(poly.map(func(x:Dot): return x.position))
		point_list_for_polys[poly] = point_list
	
	# remove the over-all convex.
	for poly :Array[Dot] in results:
		var is_valid = false
		for dot in dots:
			if poly.has(dot):
				continue
			if not Geometry2D.is_point_in_polygon(dot.position, point_list_for_polys[poly]):
				is_valid = true
				break
		if not is_valid:
			print('poly is invalid:', poly.map(func(x:Dot): return dots.find(x)))
			results.erase(poly)
	
	# remove duplicates.
	# same circles share the same point set. different circles have different point set.
	# so we use point set to remove duplicates.
	# remove duplicates.
	var new_results = []
	for i in results.size():
		var is_duplicate = false
		for j in range(i + 1, results.size()):
			if Utils.is_same_set(point_set_for_polys[results[i]], point_set_for_polys[results[j]]):
				is_duplicate = true
				break
		if not is_duplicate:
			new_results.append(results[i])
	
	results = new_results
	
	return results


func compute_circle(start_a:Dot, start_b:Dot, adjacent_map:Dictionary) -> Array[Dot]:
	const max_repeat = 100000
	var current_path :Array[Dot] = [start_a, start_b]
	for i in max_repeat:
		if i == max_repeat - 1:
			print('too many iterations!')
			break
		var next_dot = compute_next_walk(current_path[-2], current_path[-1], adjacent_map)
		if next_dot == null:
			print('no next dot! id:', dots.find(current_path[-1]))
		if next_dot == start_a:
			break
		current_path.append(next_dot)
	return current_path


func compute_next_walk(from:Dot, current:Dot, adjacent_map:Dictionary) -> Dot:
	var next_list = adjacent_map.get(current)
	var next_dot :Dot = null
	var min_angle = PI + 1
	for dot in next_list:
		if dot == from or dot == current:
			continue
		var come_from = current.position - from.position
		var go_to = dot.position - current.position
		var angle = come_from.angle_to(go_to)
		if angle < min_angle:
			next_dot = dot
			min_angle = angle
		if next_dot == null:
			return null
	return next_dot
