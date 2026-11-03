extends Node2D

const SHIELD_COLOR := Color(0.60, 0.94, 1.0, 0.82)
const SHIELD_RADIUS := 84.0
const SHIELD_CENTER := Vector2(0.0, -56.0)

var active := false
var hits_remaining := 0
var duration_remaining := 0.0
var hit_flash := 0.0

func _process(delta: float) -> void:
	hit_flash = maxf(0.0, hit_flash - delta)
	queue_redraw()

func set_state(is_active: bool, remaining_hits: int, remaining_seconds: float) -> void:
	active = is_active
	hits_remaining = remaining_hits
	duration_remaining = remaining_seconds
	visible = active
	queue_redraw()

func flash_hit() -> void:
	hit_flash = 0.24
	queue_redraw()

func _draw() -> void:
	if not active:
		return
	var pulse := 0.5 + 0.5 * sin(float(Time.get_ticks_msec()) * 0.008)
	var alpha := clampf(0.40 + pulse * 0.18 + hit_flash * 1.8, 0.0, 1.0)
	var tint := SHIELD_COLOR
	tint.a = alpha
	var radius := SHIELD_RADIUS + hit_flash * 10.0
	draw_arc(SHIELD_CENTER, radius, 0.0, TAU, 64, tint, 3.2 + hit_flash * 5.0, true)
	draw_arc(SHIELD_CENTER, radius - 5.0, -1.15, 1.15, 24, Color(0.32, 0.82, 1.0, alpha * 0.52), 1.4, true)
	for index in range(hits_remaining):
		var angle := -PI * 0.5 + (float(index) - float(hits_remaining - 1) * 0.5) * 0.24
		var pip_position := SHIELD_CENTER + Vector2(cos(angle), sin(angle)) * (radius + 2.0)
		draw_circle(pip_position, 4.0, Color(0.78, 0.98, 1.0, alpha))
