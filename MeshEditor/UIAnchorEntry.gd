extends Control

const AnchorPoint = preload("res://MeshEditor/AnchorPoint.gd")

@export
var anchor :AnchorPoint

var text :LineEdit:
	get:
		return find_child("Text")

func _ready() -> void:
	text.connect("focus_entered", on_focus_entered)
	text.connect("text_changed", on_text_changed)

func _process(_delta: float) -> void:
	if not anchor:
		return
	# if anchor.selected:
	# 	text.add_theme_color_override("background_color", Color(0.8, 1, 0.6, 1))
	# else:
	# 	text.add_theme_color_override("background_color", Color(1, 1, 1, 1))
	
	var style = StyleBoxFlat.new()
	if anchor.selected:
		style.bg_color = Color(0.1, 0.2, 0.1, 1)
	else:
		style.bg_color = Color(0.1, 0.1, 0.1, 1)
	
	# Set border color and width
	style.border_color = Color(0.2, 0.2, 0.2)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	
	text.add_theme_stylebox_override("normal", style)
	text.add_theme_stylebox_override("focus", style)
		
func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		var focus = get_viewport().gui_get_focus_owner()
		if focus and (focus is LineEdit or focus is TextEdit):
			var click_pos = event.position
			if not focus.get_global_rect().has_point(click_pos):
				focus.release_focus()

func on_focus_entered():
	anchor.selected = true

func on_text_changed(new_text:String):
	anchor.component_name = new_text

func set_source(source_anchor:AnchorPoint):
	if anchor == source_anchor:
		return
	anchor = source_anchor
	name = source_anchor.component_name
	text.text = source_anchor.component_name
