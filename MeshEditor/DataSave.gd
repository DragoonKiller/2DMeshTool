# BackupManager.gd
extends Node
class_name BackupManager

const Dot = preload("res://MeshEditor/Dot.gd")
const Segment = preload("res://MeshEditor/Segment.gd")

const file_path = "user://data.txt"

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

func serialize(dots :Array[Dot], segments :Array[Segment]):
	print("serialize!")
	# save to data.txt
	var file = ConfigFile.new()
	
	file.set_value("Dots", "_", "_")
	
	for i in dots.size():
		file.set_value("Dots", String.num_int64(i), dots[i].position)
	
	file.set_value("Segments", "_", "_")
	
	for i in segments.size():
		var from :int = segments[i].from
		var to :int = segments[i].to
		file.set_value("Segments", String.num_int64(i), Vector2i(from, to))
	
	if FileAccess.file_exists(file_path):
		Utils.copy_external_file(file_path, file_path + ".back")
	
	var backup_path = find_next_backup_file(file_path)
	print("backup! [", file_path, "] => [", backup_path, "]")
	Utils.copy_external_file(file_path, backup_path)
	
	var ok = file.save(file_path)
	if ok != OK:
		print("save error!", ok)
	
	print("save to [" + ProjectSettings.globalize_path(file_path) + "]")

func deserialize_backup(root :Node, dots :Array[Dot], segments :Array[Segment], n :int):
	var found = _get_all_backup_numbers("user://data.txt")
	if found.size() <= n:
		print('no backup can be taken!')
		return
	deserialize(root, dots, segments, "user://" + found[-n].file)
	

func deserialize(root :Node, dots :Array[Dot], segments :Array[Segment], path = file_path):
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
		var dot = Dot.new()
		dot.name = String.num_int64(i)
		dot.position = value
		dots.append(dot)
		root.add_child(dot)
	
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
		root.add_child(segment)
