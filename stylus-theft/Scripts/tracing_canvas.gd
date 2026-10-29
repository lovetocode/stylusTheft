extends Node2D

@onready var label = $ToolBar/TimeLabel
@onready var timer = $ImageTimer
@onready var top_bar = $ToolBar
@onready var reference = $reference
@onready var draw_layer = $DrawLayer
@onready var pixabay_loader: Node2D = $PixabayLoader
@onready var gallery_loader = $GalleryLoader
@onready var session_time_label = $ToolBar/session_time_label
@onready var res_loader = $ResLoader
@onready var pause_menu = $ToolBar/Pause/PauseMenu

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
	gallery_loader.scan_gallery()
	image_source_choice()
	timer.timeout.connect(_on_timer_timeout)
	top_bar.pause_requested.connect(pause_menu.open)
	pause_menu.quit_to_menu_requested.connect(_on_quit_to_menu)
	pause_menu.exit_requested.connect(_on_exit_requested)
	
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
	label.text = "img: %2d:%02d" % imageduration()
	
	if session_active == false:
		return
	sesson_elapsed += delta
	var remaining: float = max(session_time - sesson_elapsed, 0.0)
	var minutes: int = int(remaining) / 60
	var seconds: int = int(remaining) % 60
	session_time_label.text = "Sess: %d:%02d" % [minutes, seconds]
	
	if sesson_elapsed >= session_time:
		session_active = false
		timer.stop()
		await draw_layer.autosave_if_needed()
		$reference.visible = false
		$GameOverLabel.visible = true
		await get_tree().create_timer(3.0).timeout
		get_tree().change_scene_to_file("res://main.tscn")
	
func setup_top_bar():
	
	var viewport_height = get_viewport_rect().size.y
	var bar_height = clamp(viewport_height * 0.08, 50, 100)
	
	top_bar.position = Vector2(0,0)
	top_bar.size.x = get_viewport_rect().size.x
	top_bar.size.y = bar_height
	
	var vp = get_viewport().get_visible_rect().size
	reference.position = Vector2(0, bar_height)
	reference.size = Vector2(vp.x, vp.y - bar_height)
	
	draw_layer.position.y = bar_height
	draw_layer.bar_height = bar_height
	
func _on_next_requested():
	timer.stop()
	await draw_layer.autosave_if_needed()
	clear_drawing()
	timer.start()
	image_source_choice()
	
func clear_drawing():
	draw_layer.strokes.clear()
	draw_layer.dirty = false
	draw_layer.queue_redraw()
	
func _on_timer_timeout() -> void:
	if not session_active:
		return
	await draw_layer.autosave_if_needed()
	clear_drawing()
	image_source_choice()
	
func _on_quit_to_menu() -> void:
	pause_menu.close()
	await draw_layer.autosave_if_needed()
	get_tree().change_scene_to_file("res://main.tscn")
	
func _on_exit_requested() -> void:
	pause_menu.close()
	await draw_layer.autosave_if_needed()
	get_tree().quit()
	
func image_source_choice():
	if OS.has_feature("web"):
		res_loader.load_random_image()
		return
	if SessionConfig.use_gallery and SessionConfig.use_pixabay:
		if randi() % 2 == 0:
			gallery_loader.load_next_gallery_image()
		else:
			pixabay_loader.search_and_load(SessionConfig.pixabay_query)
	elif SessionConfig.use_pixabay:
		pixabay_loader.search_and_load(SessionConfig.pixabay_query)
	elif SessionConfig.use_gallery:
		gallery_loader.load_next_gallery_image()
	else:
		#OS.alert("Hit res_loader branch")
		res_loader.load_random_image()
	
		
		
		

	
	
	
