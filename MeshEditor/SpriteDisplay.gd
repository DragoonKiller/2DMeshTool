extends Sprite2D

@export
var dialog :FileDialog

@export
var image :Image

@export
var _previous_path :String
var previous_path:
	get:
		if _previous_path:
			return _previous_path
		var file = FileAccess.open("user://previous_path.txt", FileAccess.READ)
		if file == null:
			return ""
		var res = file.get_line()
		file.close()
		return res
	set(value):
		var file = FileAccess.open("user://previous_path.txt", FileAccess.WRITE)
		file.store_string(value)
		file.close()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("OpenFile"):
		if not dialog:
			dialog = FileDialog.new()
		add_child(dialog)
		dialog.connect("file_selected", on_file_selected)
		dialog.current_dir = previous_path
		dialog.access = FileDialog.ACCESS_FILESYSTEM
		dialog.use_native_dialog = true
		dialog.file_mode = FileDialog.FILE_MODE_OPEN_ANY
		dialog.filters = [
			"*.png",
			"*.jpg"
		]
		dialog.show()

func on_file_selected(path: String):
	print('select file ', path)
	previous_path = path.get_base_dir()
	
	image = Image.load_from_file(path)
	
	texture = ImageTexture.create_from_image(image)
	
	dialog.queue_free()
	dialog = null
