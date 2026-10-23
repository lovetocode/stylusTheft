extends CanvasLayer

@onready var resume_button: Button = $CenterContainer/VBoxContainer/ResumeButton
@onready var menu_button: Button = $CenterContainer/VBoxContainer/QuitToMenuButton
@onready var exit_button: Button = $CenterContainer/VBoxContainer/ExitButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	resume_button.pressed.connect(close)
	menu_button.pressed.connect(_on_menu_pressed)
	exit_button.pressed.connect(func(): get_tree().quit())
	exit_button.visible = not OS.has_feature("web")

func open() -> void:
	visible = true
	get_tree().paused = true

func close() -> void:
	visible = false
	get_tree().paused = false

func _on_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://main.tscn")

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if visible:
			close()
		else:
			open()
