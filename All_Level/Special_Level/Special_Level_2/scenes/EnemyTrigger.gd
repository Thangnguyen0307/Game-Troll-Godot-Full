extends Area2D

@export var collision_shape_2d: CollisionShape2D
@export var enemy: CharacterBody2D
@export var canvas_modulate: CanvasModulate
@export var player_light: PointLight2D

var triggered: bool = false



func _on_body_entered(body):
	if triggered:
		return
	if not body.is_in_group("player"):
		return

	triggered = true

	if enemy:
		enemy.activate()

	if canvas_modulate:
		canvas_modulate.color = Color.BLACK

	if player_light:
		player_light.enabled = true

	# 🔒 Tắt trigger
	monitoring = false
	monitorable = false
	if collision_shape_2d:
		collision_shape_2d.call_deferred("set_disabled", true)

func reset_trap(delay := 1.0):
	# ⏳ CHỜ HOẠT ẢNH CHẾT
	await get_tree().create_timer(delay).timeout

	triggered = false

	# 🌞 RESET ÁNH SÁNG MAP
	if canvas_modulate:
		canvas_modulate.color = Color.WHITE

	# 💡 TẮT ĐÈN PLAYER
	if player_light:
		player_light.enabled = false

	# 👾 RESET ENEMY
	if enemy and enemy.has_method("deactivate"):
		enemy.deactivate()

	# 🔓 BẬT LẠI TRIGGER
	monitoring = true
	monitorable = true
	if collision_shape_2d:
		collision_shape_2d.call_deferred("set_disabled", false)
