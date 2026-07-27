extends Node2D

@onready var label = $ToolBar/TimeLabel
@onready var timer = $ImageTimer
@onready var top_bar = $ToolBar
@onready var reference = $reference
@onready var draw_layer = $DrawLayer


var sesson_elapsed: float = 0.0
var session_active: bool = true
var image_time: float
var session_time: float


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_viewport().size_changed.connect(_on_viewport_resized)
	_on_viewport_resized()
	timer.wait_time = SessionConfig.image_time
	session_time = SessionConfig.session_time
	setup_top_bar()
	timer.start()
	
	
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
	
	if session_active == false:
		return
	sesson_elapsed += delta
	if sesson_elapsed >= session_time:
		session_active = false
		timer.stop()
	
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
	
	
	
