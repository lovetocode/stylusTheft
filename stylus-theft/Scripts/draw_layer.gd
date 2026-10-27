extends Node2D

@onready var tool_bar = $"../ToolBar"
@onready var texture_rect = $"../reference"
@onready var background = $"../background"


func _ready() -> void:
	tool_bar.undo_requested.connect(_on_undo_requested)
	tool_bar.save_requested.connect(_on_save_requested)
	bar_height = tool_bar.size.y
	tool_bar.brush_size_changed.connect(_on_brush_size_changed)
	tool_bar.brush_color_changed.connect(_on_brush_color_changed)
	
	
# Each stroke is an array of Vector2 points.
var strokes: Array = []
var current_points: PackedVector2Array = PackedVector2Array()
var bar_height: float = 0.0

var brush_color: Color = Color.BLACK
var brush_width: float = 3.0
var current_color: Color = Color.BLACK
var current_width: float = 3.0
var dirty := false


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.position.y < bar_height:
			return
		if event.pressed:
			# New stroke starts here.
			current_points = PackedVector2Array()
			current_points.append(to_local(event.position))
			current_width = brush_width
			current_color = brush_color
		else:
			# Finger/stylus lifted - finalize this stroke.
			if current_points.size() > 0:
				strokes.append(
					{"points": current_points,
					"width": current_width,
					"color": current_color})
				dirty = true
			current_points = PackedVector2Array()
		queue_redraw()

	elif event is InputEventScreenDrag:
		if event.position.y < bar_height:
			return
		# Stylus is moving while touching the screen.
		current_points.append(to_local(event.position))
		queue_redraw()

func _draw() -> void:
	# Draw every finished stroke.
	for stroke in strokes:
		if stroke["points"].size() > 1:
			draw_polyline(stroke["points"], stroke["color"], stroke["width"])

	# Draw the stroke currently being drawn (not yet finalized).
	if current_points.size() > 1:
		draw_polyline(current_points, current_color, current_width)

func _on_undo_requested():
	dirty = true
	if strokes.size() > 0:
		strokes.resize(strokes.size() - 1)
		queue_redraw()

func _on_save_requested():
	await save_drawing()
	
func save_drawing():
	texture_rect.visible = false
	background.visible = false
	tool_bar.visible = false
	await RenderingServer.frame_post_draw
	var img:Image = get_viewport().get_texture().get_image()
	
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("drawings"):
		dir.make_dir("drawings")
		
	img.save_png("user://drawings/drawing_%d.png" % Time.get_unix_time_from_system())
	texture_rect.visible = true
	tool_bar.visible = true
	background.visible = true
	dirty = false
	
func autosave_if_needed():
	if SessionConfig.auto_save and dirty and strokes.size() > 0:
		await save_drawing()
	
func _on_brush_size_changed(new_size: float):
		brush_width = new_size
	
func _on_brush_color_changed(new_color: Color):
	brush_color = new_color
	
