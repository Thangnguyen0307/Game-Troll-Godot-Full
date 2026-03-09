extends Area2D

@export var next_level: String = "res://Khang-Level/Khang1.tscn"
@onready var sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _on_body_entered(body):
	if body.is_in_group("Player"):
		# Phát âm thanh level up từ AudioController
		$"/root/AudioController".play_level_up()

	# process_always=true: timer tiếp tục chạy ngay cả khi game đang pause
	await get_tree().create_timer(2.0, true).timeout
	
	# Đảm bảo unpause trước khi chuyển scene (tránh scene mới bị đứng)
	get_tree().paused = false
	$AnimatedSprite2D.play("default")
