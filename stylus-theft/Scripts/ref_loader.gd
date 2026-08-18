extends Node2D

@export var images: Array[Texture2D] = []



func load_random_image():
	if images.size() == 0:
		OS.alert("no images assigned in inspector")
		return
	var chosen = images[randi() % images.size()]
	$"../reference".texture = chosen
	
