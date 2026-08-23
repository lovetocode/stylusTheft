extends Node2D


@onready var pixabay_key_field = $VBoxContainer/HBoxContainer/PixabayLineEdit



func _ready() -> void:
	pixabay_key_field.text = SessionConfig.pixabay_api_key
	$VBoxContainer/HBoxContainer2/BACK.pressed.connect(_on_back_pressed)
	$VBoxContainer/HBoxContainer2/SAVE.pressed.connect(_on_save_pressed)
	$VBoxContainer/HBoxContainer2/Paste.pressed.connect(_on_paste_pressed)
	
func _on_back_pressed():
	get_tree().change_scene_to_file("res://main.tscn")
	
	
func _on_save_pressed():
		SessionConfig.pixabay_api_key = pixabay_key_field.text
		SessionConfig.save_config()

func _on_paste_pressed() -> void:
	var text = DisplayServer.clipboard_get()
	if text:
		pixabay_key_field.text = text
	
