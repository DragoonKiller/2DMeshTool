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

var camera_zoom:
	get:
		return main_camera.zoom
