extends Control

const AnchorPoint = preload("res://MeshEditor/AnchorPoint.gd")

@export
var anchor :AnchorPoint

@onready var nameText :LineEdit = $HBoxContainer/NameText
@onready var typeText :LineEdit = $HBoxContainer/TypeText
@onready var groupText :LineEdit = $HBoxContainer/GroupText

func _ready() -> void:
	nameText.connect("focus_entered", name_on_focus_entered)
	nameText.connect("text_changed", name_on_text_changed)
	typeText.connect("focus_entered", type_on_focus_entered)
	typeText.connect("text_changed", type_on_text_changed)
	groupText.connect("text_changed", group_on_focus_entered)
	groupText.connect("text_changed", group_on_text_changed)
	

func _process(_delta: float) -> void:
	if not anchor:
		return
	# if anchor.selected:
	# 	nameText.add_theme_color_override("background_color", Color(0.8, 1, 0.6, 1))
	# else:
	# 	nameText.add_theme_color_override("background_color", Color(1, 1, 1, 1))
	
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
	
	nameText.add_theme_stylebox_override("normal", style)
	nameText.add_theme_stylebox_override("focus", style)
		
func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		var focus = get_viewport().gui_get_focus_owner()
		if focus and (focus is LineEdit or focus is TextEdit):
			var click_pos = event.position
			if not focus.get_global_rect().has_point(click_pos):
				focus.release_focus()

func name_on_focus_entered():
	anchor.selected = true

func name_on_text_changed(new_text:String):
	anchor.component_name = new_text

func type_on_focus_entered():
	anchor.selected = true

func type_on_text_changed(new_text:String):
	anchor.type_name = new_text

func group_on_focus_entered():
	anchor.selected = true

func group_on_text_changed(new_text:String):
	anchor.group_name = new_text

func set_source(source_anchor:AnchorPoint):
	if anchor == source_anchor:
		return
	anchor = source_anchor
	name = source_anchor.component_name
	nameText.text = source_anchor.component_name
	typeText.text = source_anchor.type_name
	groupText.text = source_anchor.group_name
