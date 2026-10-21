extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_viewport().size_changed.connect(_on_size_change)
	_on_size_change()
	$CenterContainer/VBoxContainer/HBoxContainer/setUp.pressed.connect(_on_setup_pressed)
	$CenterContainer/VBoxContainer/HBoxContainer/Start.pressed.connect(_on_start_pressed)
	$CenterContainer/VBoxContainer/HBoxContainer/settings.pressed.connect(_on_settings_pressed)
	$CenterContainer/VBoxContainer/HBoxContainer/Gallery.pressed.connect(_on_gallery_pressed)
	$CenterContainer/VBoxContainer/HBoxContainer/Exit.pressed.connect(_on_quit_pressed)
	$CenterContainer/VBoxContainer/HBoxContainer/Exit. visible = not OS.has_feature("web")
	
	
func _on_size_change():
	var vp_size = get_viewport_rect().size
	$background.size = vp_size
	$background.position = Vector2.ZERO
	$CenterContainer.position = Vector2.ZERO
	$CenterContainer.size = vp_size
	
func _on_setup_pressed():
	get_tree().change_scene_to_file("res://sessionsettings.tscn")

func _on_start_pressed():
	get_tree().change_scene_to_file("res://tracing_canvas.tscn")

func _on_settings_pressed():
	get_tree().change_scene_to_file("res://settings.tscn")

func _on_gallery_pressed():
	get_tree().change_scene_to_file("res://gallery.tscn")
	
func _on_quit_pressed() -> void:
	get_tree().quit()
