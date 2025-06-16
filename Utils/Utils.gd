extends Node

const Dot = preload("res://MeshEditor/Dot.gd")
const Segment = preload("res://MeshEditor/Segment.gd")

var main_camera:
	get:
		return get_viewport().get_camera_2d()

var world_visual_rect:
	get:
		return get_viewport().get_visible_rect()

var screen_top_left:
	get:
		var size = world_visual_rect.size * 0.5 / main_camera.zoom
		return main_camera.global_position - size

var screen_top_right:
	get:
		var size = world_visual_rect.size * 0.5 / main_camera.zoom
		return main_camera.global_position + Vector2(size.x, -size.y)

var screen_bottom_left:
	get:
		var size = world_visual_rect.size * 0.5 / main_camera.zoom
		return main_camera.global_position + Vector2(-size.x, size.y)

var screen_bottom_right:
	get:
		var size = world_visual_rect.size * 0.5 / main_camera.zoom
		return main_camera.global_position + size

var screen_center:
	get:
		return main_camera.global_position

var camera_zoom :float:
	get:
		return main_camera.zoom.x

var camera_zoom_scale :float:
	get:
		return 1 / main_camera.zoom.x

var _font_default :Font
var font_default:
	get:
		if not _font_default:
			var label = Label.new()
			_font_default = label.get_theme_font("")
			label.free()
		return _font_default

func copy_external_file(source_path: String, destination_path: String) -> bool:
	var source_file = FileAccess.open(source_path, FileAccess.READ)
	if not source_file:
		print("Failed to open source file")
		return false

	var dest_file = FileAccess.open(destination_path, FileAccess.WRITE)
	if not dest_file:
		print("Failed to open destination file")
		source_file.close()
		return false

	dest_file.store_buffer(source_file.get_buffer(source_file.get_length()))
	source_file.close()
	dest_file.close()
	return true

func get_keys_for_action(action_name: String) -> Array:
	var keys := []
	var events := InputMap.action_get_events(action_name)
	for e in events:
		if e is InputEventKey:
			var keycode = e.physical_keycode if e.physical_keycode != 0 else e.keycode
			var key_name = OS.get_keycode_string(keycode)
			keys.append(key_name)
		elif e is InputEventMouseButton:
			keys.append("Mouse" + str(e.button_index))
		elif e is InputEventJoypadButton:
			keys.append("Joy" + str(e.button_index))
	return keys

# Convert a comma-separated string to an Array[int]
func string_to_int_array(input: String) -> Array:
	var result: Array = []
	# Split string and process each token
	for token in input.split(",", false):
		var cleaned = token.strip_edges()
		if cleaned.is_valid_int():
			result.append(cleaned.to_int())
		else:
			push_error("Invalid integer token: '%s'" % cleaned)
	return result

# Convert an Array[int] to a comma-separated string
func int_array_to_string(arr: Array) -> String:
	var string_arr: Array = []
	for item in arr:
		if item is int:
			string_arr.append(str(item))
		else:
			push_error("Array contains non-integer value: %s" % item)
	return ", ".join(string_arr)


func draw_centered_rect(node: Node2D, center: Vector2, size: Vector2, color: Color, filled := true):
	var top_left = center - size / 2
	node.draw_rect(Rect2(top_left, size), color, filled)


static func _edge_key(a: int, b: int) -> String:
	return str(min(a, b)) + "-" + str(max(a, b))

static func _dfs(graph, visited_edges, loops, start: int, current: int, path: Array, visited_nodes: Dictionary):
	for neighbor in graph[current]:
		var key = _edge_key(current, neighbor)
		if visited_edges.has(key):
			continue
		
		visited_edges[key] = true
		path.append(neighbor)
		if neighbor == start and path.size() > 2:
			loops.append(path.duplicate())
		elif not visited_nodes.has(neighbor):
			visited_nodes[neighbor] = true
			_dfs(graph, visited_edges, loops, start, neighbor, path, visited_nodes)
			visited_nodes.erase(neighbor)
		path.pop_back()
		visited_edges.erase(key)

func find_simple_loops(dots: Array[Dot], segments: Array[Segment]) -> Array:
	# build adjacent list
	var graph = []
	graph.resize(dots.size())
	for i in range(dots.size()):
		graph[i] = []
	for seg in segments:
		graph[seg.from].append(seg.to)
		graph[seg.to].append(seg.from)
	
	var visited_edges = {}
	var loops = []
	
	for i in range(dots.size()):
		_dfs(graph, visited_edges, loops, i, i, [i], {i: true})
	
	return loops

func turn_angle(center:Vector2, a:Vector2, b:Vector2) -> float:
	return (a - center).angle_to(b - center)

func is_same_set(a:Dictionary, b:Dictionary) -> bool:
	for i in a:
		if not b.has(i):
			return false
	for i in b:
		if not a.has(i):
			return false
	return true
