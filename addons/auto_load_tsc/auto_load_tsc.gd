@tool
extends EditorPlugin

var process

func _enter_tree() -> void:
	var config = ConfigFile.new()
	var err = config.load("res://addons/auto_load_tsc/config.ini")
	if err != OK:
		print('tsc start failed!')
		return
		
	var tsc_path = config.get_value("global", "tsc_path")
	
	var cwd = ProjectSettings.globalize_path("res://tsconfig.json")
	process = OS.execute_with_pipe(tsc_path, ["--watch", "--project", cwd])
	print("tsc start watching success!")
	

func _exit_tree() -> void:
	if process != null and process.has("pid"):
		OS.kill(process["pid"])
	print("tsc stop watching!")
	
