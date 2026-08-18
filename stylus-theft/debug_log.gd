extends Node


func debug_log(msg: String) -> void:
	var file = FileAccess.open("user://debug_log.txt", FileAccess.READ_WRITE)
	if file == null:
		file = FileAccess.open("user://debug_log.txt", FileAccess.WRITE)
	else:
		file.seek_end()
	var timestamp = Time.get_datetime_string_from_system()
	file.store_line("[" + timestamp + "] " + msg)
	file.close()
