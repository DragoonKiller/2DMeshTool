extends CanvasLayer

const UIAnchorEntry = preload("res://MeshEditor/UIAnchorEntry.gd")
const UIAnchorEntryTemplate = preload("res://MeshEditor/UIAnchorEntry.tscn")
const Data = preload("res://MeshEditor/Data.gd")


@export
var data :Data

@export
var entryRoot :VBoxContainer

@export
var entries :Array[UIAnchorEntry] = []


func _process(_delta: float) -> void:
	for i in data.anchors.size():
		var anchor = data.anchors[i]
		if entries.size() <= i:
			new_entry()
		var entry :UIAnchorEntry = entries[i]
		entry.set_source(anchor)
	for i in range(data.anchors.size(), entries.size()):
		entries[i].queue_free()
	entries.resize(data.anchors.size())

func new_entry():
	var entry = UIAnchorEntryTemplate.instantiate()
	entries.append(entry)
	entryRoot.add_child(entry)
	return entry
	
