extends Area2D

@export var speed := 900.0
@export var lifetime := 1.5

var direction := Vector2.ZERO

func setup_random(player: Node2D):
	# 1️⃣ Spawn ngẫu nhiên quanh player
	var angle = randf_range(0, TAU)
	var spawn_offset = Vector2(cos(angle), sin(angle)) * 900
	global_position = player.global_position + spawn_offset

	# 2️⃣ LOCK HƯỚNG VỀ TÂM PLAYER
	direction = (player.global_position - global_position).normalized()

	# 3️⃣ Tự huỷ
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if body.is_in_group("player"):
		queue_free()   # 👻 chỉ hù
