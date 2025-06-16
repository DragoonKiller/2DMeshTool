extends Control

const AnchorPoint = preload("res://MeshEditor/AnchorPoint.gd")

@export
var anchor :AnchorPoint

var text :TextEdit:
	get:
		return find_child("Text")

func _ready() -> void:
	text.connect("focus_entered", on_focus_entered)
	text.connect("text_changed", on_text_changed)

func _process(_delta: float) -> void:
	if not anchor:
		return
	if anchor.selected:
		text.set_line_background_color(0, Color(0.2, 0.3, 0.2, 1))
	else:
		text.set_line_background_color(0, Color(0, 0, 0, 0))
		
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
