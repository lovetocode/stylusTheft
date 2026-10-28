extends CanvasLayer

signal quit_to_menu_requested
signal exit_requested

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
	exit_button.pressed.connect(func(): exit_requested.emit())

func open() -> void:
	visible = true
	get_tree().paused = true

func close() -> void:
	visible = false
	get_tree().paused = false

func _on_menu_pressed() -> void:
	quit_to_menu_requested.emit()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if visible:
			close()
		else:
			open()
