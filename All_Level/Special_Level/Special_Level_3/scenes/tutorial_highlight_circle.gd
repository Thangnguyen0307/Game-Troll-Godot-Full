extends Control
## Vẽ vòng tròn highlight màu vàng (dùng cho tutorial overlay).

func _draw() -> void:
	var center := size / 2.0
	# Vòng ngoài – viền vàng sáng
	draw_arc(center, 88.0, 0, TAU, 64, Color(1.0, 0.95, 0.0, 0.9), 3.5, true)
	# Vòng hào quang mờ bên trong
	draw_arc(center, 82.0, 0, TAU, 64, Color(1.0, 1.0, 0.4, 0.2), 12.0, true)
