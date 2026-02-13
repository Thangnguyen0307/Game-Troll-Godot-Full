extends Area2D

# Checkpoint riêng cho Special Level - KHÔNG sử dụng hệ thống level number
# Script này TÁCH BIỆT hoàn toàn với checkpoint của level thường

@export_enum("Back to Menu", "Custom Scene", "Level Select") var completion_action: String = "Level Select"
@export var next_scene_path: String = "res://All_Level/Special_Level/Special_Level_2/Special_Level_2.tscn"  # Đường dẫn scene tiếp theo
@export var special_level_name: String = "SPECIAL LEVEL"  # Tên hiển thị
@export var wait_time: float = 2.0  # Thời gian chờ trước khi chuyển scene
@onready var sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var has_triggered = false
const ConfettiEffect = preload("res://Checkpoint/confetti_rainbow.tscn")

func _ready():
	if sprite_2d:
		sprite_2d.play("default")
	print("✨ Special checkpoint ready: ", special_level_name)

func _on_body_entered(body):
	if body.is_in_group("Player") and not has_triggered:
		has_triggered = true
		spawn_confetti()
		complete_special_level()

func spawn_confetti():
	var confetti = ConfettiEffect.instantiate()
	get_parent().add_child(confetti)
	confetti.global_position = global_position + Vector2(0, -50)
	print("🎊 Confetti spawned!")

func complete_special_level():
	print("🎉 ", special_level_name, " COMPLETED! 🎉")
	print("🎯 Action: ", completion_action)
	
	# Lưu tiến độ (không ảnh hưởng current_level của level thường)
	GameManager.save_progress()
	
	# Phát âm thanh
	if has_node("/root/AudioController"):
		$"/root/AudioController".play_level_up()
	
	# Hiển thị thông báo hoàn thành
	await get_tree().create_timer(wait_time).timeout
	
	# Xử lý theo action đã chọn
	match completion_action:
		"Back to Menu":
			print("🏠 Returning to main menu...")
			_change_scene("res://Scene Main Start/main.tscn")
		
		"Custom Scene":
			if next_scene_path != "" and ResourceLoader.exists(next_scene_path):
				print("➡️ Going to: ", next_scene_path)
				_change_scene(next_scene_path)
			else:
				push_error("❌ Invalid next_scene_path: ", next_scene_path)
				_change_scene("res://Special Main Scene/special_main.tscn")
		
		"Level Select":
			print("📋 Returning to level select...")
			# TODO: Thay bằng scene level select thực tế nếu có
			_change_scene("res://Special Main Scene/SpecialLevelSelect.tscn")
		
		_:
			print("⚠️ Unknown action '", completion_action, "', returning to menu...")
			_change_scene("res://Special Main Scene/special_main.tscn")

func _change_scene(path: String):
	var result = get_tree().change_scene_to_file(path)
	if result != OK:
		push_error("❌ Failed to load scene: ", path)
