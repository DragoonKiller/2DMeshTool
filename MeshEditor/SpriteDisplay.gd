extends Sprite2D

@export
var dialog :FileDialog

@export
var image :Image

var previous_path :String:
	get:
		var file = FileAccess.open("user://previous_path.txt", FileAccess.READ)
		if file == null:
			return ""
		var res = file.get_line()
		print('get path:', res)
		return res
	set(value):
		var file = FileAccess.open("user://previous_path.txt", FileAccess.WRITE)
		file.store_string(value)

func _ready() -> void:
	var color = modulate
	color.a = 0.5
	modulate = color
	var path = previous_path
	if path != null and path != "":
		load_image(path)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("AddTransparency"):
		var color = modulate
		color.a += 0.1
		color.a = min(color.a, 1)
		modulate = color
	if event.is_action_pressed("SubTransparency"):
		var color = modulate
		color.a -= 0.1
		color.a = max(0.1, color.a)
		modulate = color
	if event.is_action_pressed("OpenFile"):
		if not dialog:
			dialog = FileDialog.new()
		if dialog.visible:
			dialog.hide()
		dialog.connect("file_selected", load_image)
		dialog.access = FileDialog.ACCESS_FILESYSTEM
		# dialog.use_native_dialog = true
		dialog.file_mode = FileDialog.FILE_MODE_OPEN_ANY
		dialog.size = Vector2(1000, 700)
		dialog.filters = [
			"*.png",
			"*.jpg"
		]
		dialog.current_dir = previous_path.get_base_dir()
		print('assigned path:', dialog.current_dir)
		add_child(dialog)
		dialog.show()

func on_file_selected(path :String):
	load_image(path)
	dialog.queue_free()
	dialog = null

func load_image(path: String):
	print('select file ', path)
	
	if not (path.ends_with("jpg") or path.ends_with("png")):
		return
		
	previous_path = path
	
	image = Image.load_from_file(path)
	
	texture = ImageTexture.create_from_image(image)

func _process(_delta: float) -> void:
	queue_redraw()


func _draw():
	if not texture:
		return
	const cell_size = 64
	var tex_size = texture.get_size() * scale
	var half_size = tex_size * 0.5
	var top_left = -half_size
	var top_right = Vector2(half_size.x, -half_size.y)
	var bottom_right = half_size
	var bottom_left = Vector2(-half_size.x, half_size.y)
	
	draw_line(top_left, top_right, Color.WHITE, -1.0)
	draw_line(top_right, bottom_right, Color.WHITE, -1.0)
	draw_line(bottom_right, bottom_left, Color.WHITE, -1.0)
	draw_line(bottom_left, top_left, Color.WHITE, -1.0)
	
	# Draw vertical grid lines
	var x = top_left.x + cell_size
	while x < bottom_right.x:
		draw_line(Vector2(x, top_left.y), Vector2(x, bottom_right.y), Color(1, 1, 1, 0.2))
		x += cell_size

	# Draw horizontal grid lines
	var y = top_left.y + cell_size
	while y < bottom_right.y:
		draw_line(Vector2(top_left.x, y), Vector2(bottom_right.x, y), Color(1, 1, 1, 0.2))
		y += cell_size
