extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if OS.get_name() == "AndAndroid":
		OS.request_permissions()
	get_viewport().size_changed.connect(_on_viewport_resized)
	_on_viewport_resized()
	
var gallery_images: Array[String] = []
var current_index: int = 0

const GALLERY_PATHS := [
	"/storage/emulated/0/Pictures",
    "/storage/emulated/0/DCIM/Camera"
]

func scan_gallery():
	pass
	
func _on_viewport_resized():
	var vp_size = get_viewport().get_visible_rect().size
	$background.size = vp_size
	$background.position = Vector2.ZERO
	
