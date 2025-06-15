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

var camera_zoom :float:
	get:
		return main_camera.zoom.x


var _font_default :Font
var font_default:
	get:
		if not _font_default:
			var label = Label.new()
			_font_default = label.get_theme_font("")
			label.free()
		return _font_default
