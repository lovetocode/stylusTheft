extends Node

var image_time: float = 120.0
var session_time:float = 600
var pixabay_query: String = "art"
var use_gallery: bool = true
var use_pixabay: bool = false

const SAVE_PATH = "user://session_config.json"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_config()
	
func save_config():
	var data = {
		"image_time": image_time,
		"session_time": session_time,
		 "pixabay_query": pixabay_query,
		"use_gallery": use_gallery,
		"use_pixabay": use_pixabay
	}
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()
	
func load_config():
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	
	if data:
		session_time = data.get("session_time", session_time)
		image_time = data.get("image_time", image_time)
		use_gallery = data.get("use_gallery", use_gallery)
		use_pixabay = data.get("use_pixabay", use_pixabay)
		pixabay_query = data.get("pixabay_query", pixabay_query)
