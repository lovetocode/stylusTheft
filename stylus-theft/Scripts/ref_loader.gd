extends Node2D


func load_random_image():
	var dir = DirAccess.open("res://images/")
	var files:Array = []
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".jpg"):
			files.append(file_name)
		file_name = dir.get_next()
	dir.list_dir_begin()
	
	var chosen = files[randi() % files.size()]
	var tex = load("res://images/" + chosen)
	$"../reference".texture = tex
