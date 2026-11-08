extends Node

signal changed

const THEMES := [
	{"name": "Classic", "white": Color.WHITE, "black": Color.BLACK, "pressed": Color(0.4, 0.7, 1.0), "border": Color.DIM_GRAY},
	{"name": "Green Terminal", "white": Color(0.04, 0.2, 0.05), "black": Color(0.0, 0.04, 0.0), "pressed": Color(0.2, 1.0, 0.3), "border": Color(0.1, 0.7, 0.2)},
	{"name": "Amber Terminal", "white": Color(0.25, 0.12, 0.0), "black": Color(0.04, 0.02, 0.0), "pressed": Color(1.0, 0.69, 0.0), "border": Color(0.8, 0.45, 0.0)},
	{"name": "Orange CRT", "white": Color(0.3, 0.1, 0.0), "black": Color(0.05, 0.02, 0.0), "pressed": Color(1.0, 0.4, 0.05), "border": Color(0.9, 0.3, 0.0)},
	{"name": "Chiptune", "white": Color(0.7, 1.0, 0.7), "black": Color(0.1, 0.25, 0.1), "pressed": Color(1.0, 0.9, 0.2), "border": Color(0.05, 0.15, 0.05)},
	{"name": "Groovy 1960s", "white": Color(1.0, 0.93, 0.6), "black": Color(0.45, 0.2, 0.05), "pressed": Color(1.0, 0.35, 0.0), "border": Color(0.55, 0.6, 0.1)},
	{"name": "Psychedelic", "white": Color(1.0, 0.6, 0.85), "black": Color(0.3, 0.0, 0.5), "pressed": Color(0.2, 0.9, 0.4), "border": Color(1.0, 0.8, 0.0)},
	{"name": "Mod Pop", "white": Color(0.95, 0.95, 0.9), "black": Color(0.05, 0.1, 0.5), "pressed": Color(0.95, 0.15, 0.2), "border": Color(1.0, 0.8, 0.1)},
	{"name": "Sunset", "white": Color(1.0, 0.9, 0.75), "black": Color(0.35, 0.1, 0.2), "pressed": Color(1.0, 0.5, 0.2), "border": Color(0.3, 0.1, 0.1)},
	{"name": "Night", "white": Color(0.25, 0.28, 0.4), "black": Color(0.05, 0.05, 0.12), "pressed": Color(0.8, 0.4, 1.0), "border": Color.BLACK},
	{"name": "Neon", "white": Color(0.1, 0.9, 1.0), "black": Color(0.15, 0.0, 0.3), "pressed": Color(1.0, 0.2, 0.8), "border": Color(0.6, 0.0, 1.0)},
]
const SAVE_PATH := "user://theme.cfg"

var index := 0
var colors: Dictionary = THEMES[0]
var theme: Theme

func _ready() -> void:
	var cf := ConfigFile.new()
	if cf.load(SAVE_PATH) == OK:
		index = clampi(int(cf.get_value("ui", "theme", 0)), 0, THEMES.size() - 1)
	rebuild()

func set_index(i: int) -> void:
	index = clampi(i, 0, THEMES.size() - 1)
	var cf := ConfigFile.new()
	cf.set_value("ui", "theme", index)
	cf.save(SAVE_PATH)
	rebuild()

func rebuild() -> void:
	colors = THEMES[index]
	theme = make_theme(colors)
	RenderingServer.set_default_clear_color(colors.black)
	changed.emit()

# Sets the theme on the top-most Controls under `root`.
# (Done by hand because themes don't reliably pass through Node2D/CanvasLayer.)
func apply_to(root: Node) -> void:
	for c in root.get_children():
		if c is Control:
			c.theme = theme
		else:
			apply_to(c)

func make_box(fill: Color, border: Color) -> StyleBoxFlat:
	var b := StyleBoxFlat.new()
	b.bg_color = fill
	b.border_color = border
	b.set_border_width_all(2)
	b.set_corner_radius_all(6)
	b.content_margin_left = 10
	b.content_margin_right = 10
	return b

func flat_box(fill: Color, border: Color, pad: float) -> StyleBoxFlat:
	var b := StyleBoxFlat.new()
	b.bg_color = fill
	b.border_color = border
	b.set_border_width_all(2)
	b.set_corner_radius_all(6)
	b.content_margin_top = pad
	b.content_margin_bottom = pad
	b.content_margin_left = pad
	b.content_margin_right = pad
	return b

func make_theme(t: Dictionary) -> Theme:
	var th := Theme.new()
	var fill: Color = t.white
	var txt: Color = t.black if fill.get_luminance() > 0.5 else t.pressed
	var on_black: Color = t.pressed if t.black.get_luminance() < 0.5 else t.white
	var normal := make_box(fill, t.border)
	var hover := make_box(fill.lerp(t.pressed, 0.35), t.border)
	var down := make_box(t.pressed, t.border)

	for cls in ["Button", "OptionButton", "MenuButton", "CheckBox"]:
		th.set_stylebox("normal", cls, normal)
		th.set_stylebox("hover", cls, hover)
		th.set_stylebox("pressed", cls, down)
		th.set_stylebox("hover_pressed", cls, down)
		th.set_stylebox("focus", cls, StyleBoxEmpty.new())
		th.set_color("font_color", cls, txt)
		th.set_color("font_hover_color", cls, txt)
		th.set_color("font_focus_color", cls, txt)
		th.set_color("font_hover_pressed_color", cls, txt)
		th.set_color("font_pressed_color", cls, t.black)

	th.set_stylebox("panel", "PopupMenu", make_box(t.black, t.border))
	th.set_stylebox("hover", "PopupMenu", make_box(t.pressed, t.border))
	th.set_color("font_color", "PopupMenu", on_black)
	th.set_color("font_hover_color", "PopupMenu", t.black)

	th.set_stylebox("slider", "HSlider", flat_box(t.black, t.border, 5.0))
	th.set_stylebox("grabber_area", "HSlider", flat_box(t.pressed, t.border, 5.0))
	th.set_stylebox("grabber_area_highlight", "HSlider", flat_box(t.pressed.lightened(0.3), t.border, 5.0))

	th.set_stylebox("normal", "LineEdit", normal)
	th.set_stylebox("focus", "LineEdit", down)
	th.set_color("font_color", "LineEdit", txt)
	th.set_color("caret_color", "LineEdit", txt)

	var te_box := flat_box(t.black, t.border, 8.0)
	th.set_stylebox("normal", "TextEdit", te_box)
	th.set_stylebox("focus", "TextEdit", te_box)
	th.set_color("background_color", "TextEdit", t.black)
	th.set_color("font_color", "TextEdit", on_black)
	th.set_color("caret_color", "TextEdit", on_black)

	th.set_stylebox("panel", "PanelContainer", make_box(t.black, t.border))
	th.set_color("font_color", "Label", on_black)
	return th
