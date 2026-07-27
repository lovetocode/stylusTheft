extends Node

var image_time: float = 120.0
var session_time:float = 600

const SAVE_PATH = "user://session_config.json"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
func save_config():
	var data = {
		"image_time": image_time,
		"session_time": session_time
	}
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()
	
func load_config():
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var data = JSON.parse_string(file.to_string())
	file.close()
	
	if data:
		image_time = data.get("image_time", image_time)
		session_time = data.get("session_time", session_time)
	
	
