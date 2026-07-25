extends HBoxContainer

signal undo_requested
signal save_requested
signal brush_size_changed(new_size: float)
signal brush_color_changed(new_color: Color)

var brush_size_min: float = 1.0
var brush_size_max: float = 40.0
var size_step: float = 0.5
var brush_size: float = 4.0

func _ready() -> void:
	$sizeLabel.text = str(brush_size)
	$Undo.pressed.connect(_on_undo_pressed)
	$Save.pressed.connect(_on_save_pressed)
	$Plus.pressed.connect(_on_plus_pressed)
	$Minus.pressed.connect(_on_minus_pressed)
	$ColorSwatch/ColorPickerPopup/ColorPicker.color_changed.connect(_on_color_picker_changed)
	$ColorSwatch/ColorPickerPopup.visible = false
	$ColorSwatch.pressed.connect(_on_color_swatch_pressed)
	
func _on_undo_pressed():
	undo_requested.emit()
	
	
func _on_save_pressed ():
	save_requested.emit()
	
	
func _on_plus_pressed()-> void:
	brush_size = clamp(brush_size + size_step, brush_size_min, brush_size_max)	
	brush_size_changed.emit(brush_size)
	update_size_label()
	

func _on_minus_pressed():
	brush_size = clamp(brush_size - size_step, brush_size_min, brush_size_max)
	brush_size_changed.emit(brush_size)
	update_size_label()
	
func update_size_label():
	$sizeLabel.text = "%.1f" % brush_size
	
func _on_color_picker_changed(new_color: Color):
	brush_color_changed.emit(new_color)
	
	
func _on_color_swatch_pressed() -> void:
	$ColorSwatch/ColorPickerPopup.visible = !$ColorSwatch/ColorPickerPopup.visible
	
