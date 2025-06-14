extends Node

var default_font :Font

func get_default_font():
	if not default_font:
		# Accessing the default font in code
		var label = Label.new()
		default_font = label.get_theme_font("") # Gets the default font used by the label
		label.free()
	return default_font
	
