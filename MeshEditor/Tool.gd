@tool
extends Node

const Data = preload("res://MeshEditor/Data.gd")

@export
var data :Data

func _ready() -> void:
	await get_tree().create_timer(1).timeout
	print('offset execute!')
