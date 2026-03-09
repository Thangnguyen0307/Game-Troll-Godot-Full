extends CanvasLayer
## Tutorial overlay hiện circle highlight quanh nút Jump + dòng chữ hướng dẫn.
## Tự fade-in khi vào level, sau SHOW_DURATION giây sẽ tự fade-out và giải phóng.

const SHOW_DURATION := 5.0      ## Thời gian hiện tutorial (giây)
const FADE_IN_TIME  := 0.6
const FADE_OUT_TIME := 1.5

@onready var container: Control = $Container
@onready var circle: Control    = $Container/CircleHighlight
@onready var label_node: Label  = $Container/TutorialLabel

var _pulse_tween: Tween
var _is_fading := false


func _ready() -> void:
	# ---------- fade-in ----------
	container.modulate.a = 0.0
	var fade_in := create_tween()
	fade_in.tween_property(container, "modulate:a", 1.0, FADE_IN_TIME)

	# ---------- circle zoom in / out ----------
	_start_pulse()

	# ---------- tự động biến mất sau N giây ----------
	await get_tree().create_timer(SHOW_DURATION).timeout
	_fade_out()


func _start_pulse() -> void:
	_pulse_tween = create_tween().set_loops()
	_pulse_tween.tween_property(circle, "scale", Vector2(1.18, 1.18), 0.55) \
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	_pulse_tween.tween_property(circle, "scale", Vector2(0.88, 0.88), 0.55) \
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)


func _fade_out() -> void:
	if _is_fading:
		return
	_is_fading = true

	if _pulse_tween and _pulse_tween.is_valid():
		_pulse_tween.kill()

	var fade := create_tween()
	fade.tween_property(container, "modulate:a", 0.0, FADE_OUT_TIME) \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	fade.tween_callback(queue_free)
