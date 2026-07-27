extends Node2D

@onready var tool_bar = $"../ToolBar"
@onready var texture_rect = $"../reference"



func _ready() -> void:
	tool_bar.undo_requested.connect(_on_undo_requested)
	tool_bar.save_requested.connect(_on_save_requested)
	bar_height = tool_bar.size.y
	tool_bar.brush_size_changed.connect(_on_brush_size_changed)
	tool_bar.brush_color_changed.connect(_on_brush_color_changed)
	
	
# Each stroke is an array of Vector2 points.
var strokes: Array = []
var current_stroke: PackedVector2Array = PackedVector2Array()
var bar_height: float = 0.0

var brush_color: Color = Color.BLACK
var brush_width: float = 3.0

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.position.y < bar_height:
			return
		if event.pressed:
			# New stroke starts here.
			current_stroke = PackedVector2Array()
			current_stroke.append(to_local(event.position))
		else:
			# Finger/stylus lifted - finalize this stroke.
			if current_stroke.size() > 0:
				strokes.append(current_stroke)
			current_stroke = PackedVector2Array()
		queue_redraw()

	elif event is InputEventScreenDrag:
		if event.position.y < bar_height:
			return
		# Stylus is moving while touching the screen.
		current_stroke.append(to_local(event.position))
		queue_redraw()

func _draw() -> void:
	# Draw every finished stroke.
	for stroke in strokes:
		if stroke.size() > 1:
			draw_polyline(stroke, brush_color, brush_width)

	# Draw the stroke currently being drawn (not yet finalized).
	if current_stroke.size() > 1:
		draw_polyline(current_stroke, brush_color, brush_width)

func _on_undo_requested():
	if strokes.size() > 0:
		strokes.resize(strokes.size() - 1)
		queue_redraw()

func _on_save_requested():
	texture_rect.visible = false
	await RenderingServer.frame_post_draw
	var img:Image = get_viewport().get_texture().get_image()
	img.save_png("user://drawing_%d.png" % Time.get_unix_time_from_system())
	texture_rect.visible = true
	
func _on_brush_size_changed(new_size: float):
		brush_width = new_size
	
func _on_brush_color_changed(new_color: Color):
	brush_color = new_color
	
