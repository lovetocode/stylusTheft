extends Node2D

@onready var label = $ToolBar/Label
@onready var timer = $ImageTimer
@onready var top_bar = $ToolBar
@onready var reference = $reference
@onready var draw_layer = $DrawLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_viewport().size_changed.connect(_on_viewport_resized)
	_on_viewport_resized()
	timer.wait_time = 100	
	timer.start()
	setup_top_bar()
	
func _on_viewport_resized():
	var vp_size = get_viewport().get_visible_rect().size
	$background.size = vp_size
	$background.position = Vector2.ZERO
	
func imageduration():
	var minutes = floor(timer.time_left / 60)
	var seconds = int(timer.time_left) % 60
	return [minutes, seconds]
	
func _process(delta: float) -> void:
	label.text = "%02d:%02d" % imageduration()
	
func setup_top_bar():
	
	var viewport_height = get_viewport_rect().size.y
	var bar_height = clamp(viewport_height * 0.08, 50, 100)
	
	top_bar.position = Vector2(0,0)
	top_bar.size.x = get_viewport_rect().size.x
	top_bar.size.y = bar_height
	
	reference.size.y -= bar_height
	reference.position.y = bar_height
	
	draw_layer.position.y = bar_height
	draw_layer.bar_height = bar_height
	
	
