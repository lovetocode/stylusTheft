extends Node2D

@onready var label = $ToolBar/TimeLabel
@onready var timer = $ImageTimer
@onready var top_bar = $ToolBar
@onready var reference = $reference
@onready var draw_layer = $DrawLayer
@onready var pixabay_loader: Node2D = $PixabayLoader
@onready var gallery_loader = $GalleryLoader


var sesson_elapsed: float = 0.0
var session_active: bool = true
var session_time: float


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_viewport().size_changed.connect(_on_viewport_resized)
	_on_viewport_resized()
	timer.wait_time = SessionConfig.image_time
	session_time = SessionConfig.session_time
	setup_top_bar()
	timer.start()
	pixabay_loader.image_ready.connect(_on_pixabay_image_ready)
	top_bar.next_requested.connect(_on_next_requested)
	if OS.get_name() == "Android":
		OS.request_permissions()
	#gallery_loader.scan_gallery()
	#gallery_loader.load_next_gallery_image()
	pixabay_loader.search_and_load(SessionConfig.pixabay_query)
	
	
func _on_pixabay_image_ready(texture: ImageTexture) -> void:
	reference.texture = texture
	
	
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
	
func _on_next_requested():
	timer.stop()
	clear_drawing()
	timer.start()
	gallery_loader.load_next_gallery_image()
	
func clear_drawing():
	draw_layer.strokes.clear()
	draw_layer.queue_redraw()
	
func _on_timer_timeout() -> void:
	clear_drawing()
	gallery_loader.load_next_gallery_image()
	pixabay_loader.search_and_load(SessionConfig.pixabay_query)
	

	
	
	
