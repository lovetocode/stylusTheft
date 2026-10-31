extends HBoxContainer

signal undo_requested
signal save_requested
signal next_requested
signal brush_size_changed(new_size: float)
signal brush_color_changed(new_color: Color)
signal pause_requested

var brush_size_min: float = 1.0
var brush_size_max: float = 40.0
var size_step: float = 0.5
var brush_size: float = 4.0
var repeat_dir := 0
var repeat_timer := Timer.new()

func _ready() -> void:
	$sizeLabel.text = str(brush_size)
	$Undo.pressed.connect(_on_undo_pressed)
	$Save.pressed.connect(_on_save_pressed)
	$ColorSwatch/ColorPickerPopup/ColorPicker.color_changed.connect(_on_color_picker_changed)
	$ColorSwatch/ColorPickerPopup.visible = false
	$ColorSwatch.pressed.connect(_on_color_swatch_pressed)
	$Next.pressed.connect(_on_next_pressed)
	$Pause.pressed.connect(_on_pause_requested)
	add_child(repeat_timer)
	repeat_timer.timeout.connect(_on_repeat)
	$Plus.button_down.connect(_start_repeat.bind(1))
	$Plus.button_up.connect(_stop_repeat)
	$Minus.button_down.connect(_start_repeat.bind(-1))
	$Minus.button_up.connect(_stop_repeat)
	
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
	
func _on_next_pressed():
	next_requested.emit()
	
func _on_pause_requested():
	pause_requested.emit()

func _start_repeat(dir: int) -> void:
	_change_size(dir)              # one step right away
	repeat_dir = dir
	repeat_timer.start(0.4)        # wait before repeating

func _stop_repeat() -> void:
	repeat_timer.stop()

func _on_repeat() -> void:
	repeat_timer.wait_time = 0.08  # then repeat quickly
	_change_size(repeat_dir)

func _change_size(dir: int) -> void:
	brush_size = clamp(brush_size + dir * size_step, brush_size_min, brush_size_max)
	brush_size_changed.emit(brush_size)
	update_size_label()
	
	
