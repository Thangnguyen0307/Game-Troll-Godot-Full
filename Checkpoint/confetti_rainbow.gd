extends GPUParticles2D
# Rainbow confetti with stars - Intense celebration effect

func _ready():
	emitting = true
	one_shot = true
	
	# Tự động xóa sau khi effect kết thúc
	await get_tree().create_timer(lifetime + 1.5).timeout
	queue_free()

static func spawn_at(position: Vector2, parent: Node, offset: Vector2 = Vector2(0, -50)) -> void:
	var confetti_scene = preload("res://Checkpoint/confetti_rainbow.tscn")
	var confetti = confetti_scene.instantiate()
	parent.add_child(confetti)
	confetti.global_position = position + offset
	print("🌈✨ Rainbow confetti spawned!")
