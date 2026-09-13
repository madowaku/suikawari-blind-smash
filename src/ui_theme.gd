extends RefCounted

const BACKGROUND := Color("f4e8cf")
const SURFACE := Color("fff8e9")
const SURFACE_MUTED := Color("ead9b6")
const FOREGROUND := Color("2b3038")
const FOREGROUND_MUTED := Color("726c60")
const PRIMARY := Color("3b9bc3")
const PRIMARY_DARK := Color("257da3")
const SECONDARY := Color("f2c14e")
const ACCENT := Color("e85d3f")
const ACCENT_DARK := Color("c7462e")
const BORDER := Color("b79b69")
const HOTTER_BG := Color("f8d9cf")
const COLDER_BG := Color("d7edf6")
const SAME_BG := Color("e5dfd4")
const KNOCK_BG := Color("f7e2b4")
const SUCCESS_BG := Color("d9efd9")
const FAIL_BG := Color("f4d0ca")


static func build_theme() -> Theme:
	var theme := Theme.new()
	theme.set_color("font_color", "Label", FOREGROUND)
	theme.set_color("font_shadow_color", "Label", Color(0, 0, 0, 0))
	theme.set_font_size("font_size", "Label", 15)
	theme.set_color("font_color", "Button", FOREGROUND)
	theme.set_color("font_hover_color", "Button", FOREGROUND)
	theme.set_color("font_pressed_color", "Button", Color.WHITE)
	theme.set_color("font_disabled_color", "Button", Color(0.45, 0.43, 0.39, 0.62))
	theme.set_font_size("font_size", "Button", 16)
	theme.set_stylebox("normal", "Button", box(SURFACE_MUTED, BORDER, 10, 1, 8))
	theme.set_stylebox("hover", "Button", box(Color("f4e5c8"), BORDER, 10, 1, 8))
	theme.set_stylebox("pressed", "Button", box(PRIMARY, PRIMARY_DARK, 10, 2, 8))
	theme.set_stylebox("disabled", "Button", box(Color("e4dccd"), Color("c8bca9"), 10, 1, 8))
	theme.set_stylebox("focus", "Button", box(Color(0, 0, 0, 0), PRIMARY, 10, 2, 6))
	return theme


static func box(
	background: Color,
	border: Color = Color.TRANSPARENT,
	radius: int = 12,
	border_width: int = 0,
	padding: float = 0.0
) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.content_margin_left = padding
	style.content_margin_top = padding
	style.content_margin_right = padding
	style.content_margin_bottom = padding
	return style
