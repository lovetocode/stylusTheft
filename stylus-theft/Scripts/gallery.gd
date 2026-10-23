extends Node2D

@onready var grid: GridContainer = $ScrollContainer/GridContainer
@onready var back_button: Button = $BackButton
@onready var viewer: CanvasLayer = $Viewer
@onready var full_image: TextureRect = $Viewer/FullImage
@onready var close_button: Button = $Viewer/Buttons/CloseButton
@onready var export_button: Button = $Viewer/Buttons/ExportButton
@onready var delete_button: Button = $Viewer/Buttons/DeleteButton

const DRAWINGS_PATH = "user://drawings/"
const THUMB_SIZE = Vector2(350, 350)

var current_path := ""
var delete_armed := false
var thumbs := {}   # path -> thumbnail button

func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	close_button.pressed.connect(_close_viewer)
	export_button.pressed.connect(_on_export_pressed)
	delete_button.pressed.connect(_on_delete_pressed)
	get_viewport().size_changed.connect(_on_viewport_resized)
	_on_viewport_resized()
	viewer.visible = false
	load_drawings()
	full_image.offset_bottom = -150

func _on_viewport_resized() -> void:
	var vp_size = get_viewport_rect().size
	$ScrollContainer.position = Vector2.ZERO
	$ScrollContainer.size = vp_size

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://main.tscn")

func load_drawings() -> void:
	DirAccess.make_dir_recursive_absolute(DRAWINGS_PATH)
	var files := Array(DirAccess.get_files_at(DRAWINGS_PATH))
	files = files.filter(func(f): return f.ends_with(".png"))
	files.sort()
	files.reverse()   # newest first (filenames contain the timestamp)
	for f in files:
		add_thumbnail(DRAWINGS_PATH + f)

func add_thumbnail(path: String) -> void:
	var image := Image.load_from_file(path)
	if image == null:
		return
	var btn := TextureButton.new()
	btn.texture_normal = ImageTexture.create_from_image(image)
	btn.ignore_texture_size = true
	btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	btn.custom_minimum_size = THUMB_SIZE
	btn.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	btn.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	btn.pressed.connect(_open_viewer.bind(path))
	grid.add_child(btn)
	thumbs[path] = btn

func _open_viewer(path: String) -> void:
	var image := Image.load_from_file(path)
	if image == null:
		OS.alert("Could not open " + path)
		return
	current_path = path
	full_image.texture = ImageTexture.create_from_image(image)
	_reset_delete()
	viewer.visible = true

func _close_viewer() -> void:
	viewer.visible = false
	full_image.texture = null
	current_path = ""
	_reset_delete()

func _reset_delete() -> void:
	delete_armed = false
	delete_button.text = "Delete"

func _on_delete_pressed() -> void:
	if not delete_armed:
		delete_armed = true
		delete_button.text = "Tap again to delete"
		return
	var err := DirAccess.remove_absolute(current_path)
	if err != OK:
		OS.alert("Delete failed: " + error_string(err))
		return
	thumbs[current_path].queue_free()
	thumbs.erase(current_path)
	_close_viewer()

func _on_export_pressed() -> void:
	export_drawing(current_path)

func export_drawing(src: String) -> void:
	var folder = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS) + "/StylusTheft"
	DirAccess.make_dir_recursive_absolute(folder)
	var dest = folder + "/" + src.get_file()
	var err = DirAccess.copy_absolute(ProjectSettings.globalize_path(src), dest)
	OS.alert("Export: %s\n%s" % [error_string(err), dest])

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if viewer.visible:
			_close_viewer()
		else:
			_on_back_pressed()
