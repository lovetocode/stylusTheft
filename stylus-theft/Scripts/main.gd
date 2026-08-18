extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_viewport().size_changed.connect(_on_size_change)
	_on_size_change()
	$CenterContainer/HBoxContainer/setUp.pressed.connect(_on_setup_pressed)
	$CenterContainer/HBoxContainer/Start.pressed.connect(_on_start_pressed)
	$CenterContainer/HBoxContainer/settings.pressed.connect(_on_settings_pressed)
	
	
func _on_size_change():
	var vp_size = get_viewport_rect().size
	$background.size = vp_size
	$background.position = Vector2.ZERO
	
func _on_setup_pressed():
	get_tree().change_scene_to_file("res://sessionsettings.tscn")

func _on_start_pressed():
	get_tree().change_scene_to_file("res://tracing_canvas.tscn")

func _on_settings_pressed():
	get_tree().change_scene_to_file("res://settings.tscn")
