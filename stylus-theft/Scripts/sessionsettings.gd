extends Node2D

@onready var pixabay_search_field: LineEdit = $VBoxContainer/HBoxContainer3/PixabaySearchField
@onready var image_time: SpinBox = $VBoxContainer/HBoxContainer2/ImageTimeInput
@onready var session_time: SpinBox  = $VBoxContainer/HBoxContainer/SessionTimeInput

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_viewport().size_changed.connect(_on_size_changed)
	_on_size_changed()
	$Back.pressed.connect(_on_back_pressed)
	$Save.pressed.connect(_on_save_pressed)
	pixabay_search_field.text = SessionConfig.pixabay_query
	session_time.value = SessionConfig.session_time
	image_time.value = SessionConfig.image_time

	
func _on_size_changed():
	var vp_size = get_viewport_rect().size
	$background.size = vp_size
	$background.position = Vector2.ZERO
	
	
func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://main.tscn")
	
func _on_save_pressed() -> void:
	if pixabay_search_field.text.strip_edges() != "" :
		SessionConfig.pixabay_query = pixabay_search_field.text
		
	SessionConfig.image_time = image_time.value
	SessionConfig.session_time = session_time.value
	
	SessionConfig.save_config()
	
