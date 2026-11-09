extends Node2D

@onready var pixabay_search_field: LineEdit = $VBoxContainer/HBoxContainer3/PixabaySearchField
@onready var image_time: SpinBox = $VBoxContainer/HBoxContainer2/ImageTimeInput
@onready var session_time: SpinBox  = $VBoxContainer/HBoxContainer/SessionTimeInput
@onready var use_gallery_checkbox: CheckBox = $VBoxContainer/HBoxContainer4/UseGalleryCheckbox
@onready var use_pixabay_checkbox: CheckBox = $VBoxContainer/HBoxContainer4/UsePixabayCheckbox
@onready var auto_save_checkbox: CheckBox = $VBoxContainer/HBoxContainer4/AutoSaveCheckbox

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if OS.has_feature("web"):
		use_gallery_checkbox.hide()
		SessionConfig.use_gallery = false
		SessionConfig.use_pixabay = true
	get_viewport().size_changed.connect(_on_size_changed)
	_on_size_changed()
	$VBoxContainer/HBoxContainer5/Back.pressed.connect(_on_back_pressed)
	$VBoxContainer/HBoxContainer5/Save.pressed.connect(_on_save_pressed)
	pixabay_search_field.text = SessionConfig.pixabay_query
	session_time.value = SessionConfig.session_time / 60
	image_time.value = SessionConfig.image_time / 60
	use_gallery_checkbox.button_pressed = SessionConfig.use_gallery
	use_pixabay_checkbox.button_pressed = SessionConfig.use_pixabay
	auto_save_checkbox.button_pressed = SessionConfig.auto_save
	AppTheme.apply_to(self)
	_sync_bg()
	
	
func _on_size_changed():
	var vp_size = get_viewport_rect().size
	$background.size = vp_size
	$background.position = Vector2.ZERO
	
	
func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://main.tscn")
	
func _on_save_pressed() -> void:
	SessionConfig.use_gallery = false if OS.has_feature("web") else use_gallery_checkbox.button_pressed
	if pixabay_search_field.text.strip_edges() != "" :
		SessionConfig.pixabay_query = pixabay_search_field.text
		
	SessionConfig.image_time = image_time.value * 60
	SessionConfig.session_time = session_time.value * 60
	SessionConfig.use_gallery = use_gallery_checkbox.button_pressed
	SessionConfig.use_pixabay = use_pixabay_checkbox.button_pressed
	SessionConfig.auto_save = auto_save_checkbox.button_pressed
	SessionConfig.save_config()
	
func _sync_bg() -> void:
	$background.color = AppTheme.colors.black
