extends Node

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
