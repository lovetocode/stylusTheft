extends Node2D


@onready var pixabay_key_field = $VBoxContainer/HBoxContainer/PixabayLineEdit



func _ready() -> void:
	pixabay_key_field.text = SessionConfig.pixabay_api_key
	$VBoxContainer/HBoxContainer3/BACK.pressed.connect(_on_back_pressed)
	$VBoxContainer/HBoxContainer2/SAVE.pressed.connect(_on_save_pressed)
	$VBoxContainer/HBoxContainer2/Paste.pressed.connect(_on_paste_pressed)
	var picker := OptionButton.new()
	picker.custom_minimum_size = Vector2(200, 50)
	for t in AppTheme.THEMES:
		picker.add_item(t.name)
	picker.select(AppTheme.index)
	picker.item_selected.connect(func(i: int):
		AppTheme.set_index(i)
		AppTheme.apply_to(self)
		_sync_bg())
	$VBoxContainer/HBoxContainer3.add_child(picker)
	AppTheme.apply_to(self)
	_sync_bg()
	
func _on_back_pressed():
	get_tree().change_scene_to_file("res://main.tscn")
	
	
func _on_save_pressed():
		SessionConfig.pixabay_api_key = pixabay_key_field.text
		SessionConfig.save_config()

func _on_paste_pressed() -> void:
	var text = DisplayServer.clipboard_get()
	if text:
		pixabay_key_field.text = text
		
func _sync_bg() -> void:
	$background.color = AppTheme.colors.black
	
