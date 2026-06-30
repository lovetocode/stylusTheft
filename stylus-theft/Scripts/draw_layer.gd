extends Node2D

# Each stroke is an array of Vector2 points.
var strokes: Array = []
var current_stroke: PackedVector2Array = PackedVector2Array()

var brush_color: Color = Color.BLACK
var brush_width: float = 3.0

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			# New stroke starts here.
			current_stroke = PackedVector2Array()
			current_stroke.append(event.position)
		else:
			# Finger/stylus lifted - finalize this stroke.
			if current_stroke.size() > 0:
				strokes.append(current_stroke)
			current_stroke = PackedVector2Array()
		queue_redraw()

	elif event is InputEventScreenDrag:
		# Stylus is moving while touching the screen.
		current_stroke.append(event.position)
		queue_redraw()

func _draw() -> void:
	# Draw every finished stroke.
	for stroke in strokes:
		if stroke.size() > 1:
			draw_polyline(stroke, brush_color, brush_width)

	# Draw the stroke currently being drawn (not yet finalized).
	if current_stroke.size() > 1:
		draw_polyline(current_stroke, brush_color, brush_width)
