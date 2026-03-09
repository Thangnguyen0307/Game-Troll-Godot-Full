extends Area2D

@export var completed_level_number: int = 1  # Level vừa hoàn thành (Level 1)
@export var next_level: String = "res://All_Level/Map Level 2/Level_2.tscn"
@onready var sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var has_triggered = false
const ConfettiEffect = preload("res://Checkpoint/confetti_rainbow.tscn")
func _ready():
	sprite_2d.play("default")
	
	# KHÔNG update current_level tự động
	print("Checkpoint ready for level ", completed_level_number)

func _on_body_entered(body):
	if body.is_in_group("Player") and not has_triggered:
		has_triggered = true
		spawn_confetti()
		complete_level()

func spawn_confetti():
	var confetti = ConfettiEffect.instantiate()
	get_parent().add_child(confetti)
	confetti.global_position = global_position + Vector2(0, -50)
	print("🎊 Confetti spawned!")

func complete_level():
	print("🎉 LEVEL ", completed_level_number, " COMPLETED! 🎉")
	
	# Đảm bảo current_level đúng trước khi unlockd
	if GameManager.current_level != completed_level_number:
		print("Syncing current_level from ", GameManager.current_level, " to ", completed_level_number)
		GameManager.current_level = completed_level_number
	
	# UNLOCK level tiếp theo
	GameManager.unlock_next_level()
	
	# Debug
	print("Current level: ", GameManager.current_level)
	print("Max level unlocked: ", GameManager.max_level_unlocked)
	print("Next level path: ", next_level)
	
	# Phát âm thanh
	$"/root/AudioController".play_level_up()

	# process_always=true: timer tiếp tục chạy ngay cả khi game đang pause
	await get_tree().create_timer(2.0, true).timeout
	
	# Đảm bảo unpause trước khi chuyển scene (tránh scene mới bị đứng)
	get_tree().paused = false

	# Chuyển sang level tiếp theo bằng GameManager
	var next_level_number = completed_level_number + 1
	print("Going to next level: ", next_level_number)
	GameManager.go_to_level(next_level_number)
