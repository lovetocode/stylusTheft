extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_viewport().size_changed.connect(_on_viewport_resized)
	_on_viewport_resized()
	
func _on_viewport_resized():
	var vp_size = get_viewport().get_visible_rect().size
	$background.size = vp_size
	$background.position = Vector2.ZERO
