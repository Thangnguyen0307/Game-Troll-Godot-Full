extends GPUParticles2D
# Hiệu ứng pháo giấy cho checkpoint

func _ready():
	# Tự động phát hiệu ứng khi được tạo
	emitting = true
	one_shot = true
	
	# Tự động xóa sau khi hiệu ứng kết thúc
	await get_tree().create_timer(lifetime + 1.0).timeout
	queue_free()

# Static function để spawn confetti từ bất kỳ đâu
static func spawn_at(position: Vector2, parent: Node) -> void:
	var confetti_scene = preload("res://Checkpoint/confetti_effect.tscn")
	var confetti = confetti_scene.instantiate()
	parent.add_child(confetti)
	confetti.global_position = position
	print("🎉 Confetti spawned at ", position)
