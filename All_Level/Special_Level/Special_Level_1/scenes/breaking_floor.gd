extends StaticBody2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
# Nếu bạn có Sprite2D riêng thì dùng biến này, còn nếu không thì tween "self" cũng được


var is_triggered = false

# Cấu hình thời gian (Giây)
const WARNING_DURATION = 2.0  # Thời gian nhấp nháy báo hiệu
const RESPAWN_TIME = 3.0      # Thời gian biến mất bao lâu thì hiện lại

func _on_trigger_area_body_entered(body: Node2D) -> void:
	# Chỉ kích hoạt nếu là Player và bục đang chưa bị kích hoạt
	if body.is_in_group("Player") and not is_triggered:
		is_triggered = true
		start_disappearing_cycle()

func start_disappearing_cycle() -> void:
	# --- GIAI ĐOẠN 1: BÁO HIỆU (NHẤP NHÁY) ---
	var tween = create_tween()
	
	# Lặp lại hiệu ứng nhấp nháy 6 lần trong khoảng thời gian WARNING_DURATION
	# Mỗi lần nháy gồm: Mờ đi -> Sáng lại
	var loops = 6
	var single_flash_time = WARNING_DURATION / (loops * 2) 
	
	for i in range(loops):
		# Giảm alpha xuống 0.2 (mờ)
		tween.tween_property(self, "modulate:a", 0.2, single_flash_time)
		# Tăng alpha lên 1.0 (sáng)
		tween.tween_property(self, "modulate:a", 1.0, single_flash_time)
	
	# Đợi cho cái tween nhấp nháy này chạy xong mới làm tiếp
	await tween.finished
	
	# --- GIAI ĐOẠN 2: BIẾN MẤT ---
	# Tắt va chạm (Người chơi sẽ rơi)
	collision_shape_2d.set_deferred("disabled", true)
	# Ẩn hình ảnh hoàn toàn
	modulate.a = 0.0 
	
	# --- GIAI ĐOẠN 3: ĐỢI HỒI SINH ---
	# Tạo một bộ đếm giờ ảo và đợi nó chạy xong (thay thế cho node Timer)
	await get_tree().create_timer(RESPAWN_TIME).timeout
	
	# --- GIAI ĐOẠN 4: HIỆN LẠI ---
	# Bật lại hình ảnh
	var appear_tween = create_tween()
	appear_tween.tween_property(self, "modulate:a", 1.0, 0.5) # Hiện dần lên trong 0.5s cho đẹp
	
	# Bật lại va chạm
	collision_shape_2d.set_deferred("disabled", false)
	
	# Reset biến cờ để người chơi có thể kích hoạt lại lần nữa
	is_triggered = false
