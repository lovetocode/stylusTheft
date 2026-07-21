extends Node2D



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if OS.get_name() == "Android":
		OS.request_permissions()
	scan_gallery()
	load_next_gallery_image()

	
	
		
var gallery_images: Array[String] = []
var current_index: int = 0

const GALLERY_PATHS := [
	"/storage/emulated/0/Pictures",
    "/storage/emulated/0/DCIM/Camera"
]

func scan_gallery():
	gallery_images.clear()
	for folder_path in GALLERY_PATHS:
		var dir = DirAccess.open(folder_path)
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if not dir.current_is_dir() and _is_image(file_name):
				gallery_images.append(folder_path + "/" + file_name)
			
			file_name = dir.get_next()
			
		dir.list_dir_end()
			
	gallery_images.shuffle()
			
	
func _is_image(file_name: String) ->  bool:
	var lower = file_name.to_lower()
	return lower.ends_with(".jpg") or lower.ends_with(".jpeg") or lower.ends_with(".png")
	
func load_next_gallery_image():
	if gallery_images.is_empty():
		return
		
	var path = gallery_images[current_index]
	current_index = (current_index + 1) % gallery_images.size()
	var image := Image.new()
	
	var err := image.load(path)
	if err != OK:
		push_warning("Failed to load image " + path)
		load_next_gallery_image()
		return
	
	var texture = ImageTexture.create_from_image(image)
	
	$"../reference".texture = texture
	
func _on_timer_timeout() -> void:
	load_next_gallery_image()
