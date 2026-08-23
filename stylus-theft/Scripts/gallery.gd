extends Node2D

@onready var grid: GridContainer = $ScrollContainer/GridContainer
@onready var back_button: Button = $BackButton

const DRAWINGS_PATH = "user://drawings/"
const THUMB_SIZE = Vector2(350, 350)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_viewport().size_changed.connect(_on_viewport_resized)
	_on_viewport_resized()
	back_button.pressed.connect(_on_back_pressed)
	load_drawings()
	
func _on_back_pressed():
	get_tree().change_scene_to_file("res://main.tscn")
	
func load_drawings():
	var dir = DirAccess.open(DRAWINGS_PATH)
	if dir == null:
		OS.alert("Could not open drawings: " + DRAWINGS_PATH)
		return
		
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir()  and file_name.ends_with(".png"):
			add_thumbnail(DRAWINGS_PATH + file_name)
		file_name = dir.get_next()
	dir.list_dir_begin()

func  add_thumbnail(path: String) -> void:
	var image = Image.new()
	var err = image.load(path)
	if err != OK:
		OS.alert("ERROR LOADING IMAGE " + path)
		return
		
	var texture = ImageTexture.create_from_image(image)
	var tex_rect = TextureRect.new()
	tex_rect.texture = texture
	tex_rect.custom_minimum_size = THUMB_SIZE
	tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tex_rect.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	tex_rect.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	grid.add_child(tex_rect)
	
func _on_viewport_resized() -> void:
	var vp_size = get_viewport_rect().size
	$ScrollContainer.position = Vector2.ZERO
	$ScrollContainer.size = vp_size
