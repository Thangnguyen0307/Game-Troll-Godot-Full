extends Area2D

func _on_body_entered(body):
	if not body.is_in_group("player"):
		return

	body.is_hiding = true
	body.velocity = Vector2.ZERO
	body.sprite_2d.animation = "Idle"
	body.sprite_2d.modulate = Color(0.6, 0.6, 0.6)

	# ❗ QUAN TRỌNG: tắt va chạm với enemy
	body.set_collision_mask_value(3, false) # enemy = layer 3


func _on_body_exited(body):
	if not body.is_in_group("player"):
		return

	body.is_hiding = false
	body.sprite_2d.modulate = Color.WHITE

	# bật lại va chạm
	body.set_collision_mask_value(3, true)
