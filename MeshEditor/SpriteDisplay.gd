extends Sprite2D

@export
var dialog :FileDialog

@export
var image :Image

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("OpenFile"):
		if not dialog:
			dialog = FileDialog.new()
		add_child(dialog)
		dialog.connect("file_selected", on_file_selected)
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
	
	image = Image.load_from_file(path)
	
	texture = ImageTexture.create_from_image(image)
	
	dialog.queue_free()
	dialog = null
