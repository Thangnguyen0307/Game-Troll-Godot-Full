extends Node2D

var tween: Tween

# Đường dẫn scene
const MAIN_SCENE := "res://Scene Main Start/main.tscn"
const SPECIAL_SCENE := "res://Special Main Scene/special_main.tscn"

# Đường dẫn Menu chọn level (Bạn cần tạo thêm cái SpecialLevelSelect)
const MAIN_LEVEL_SELECT := "res://UI/level_select_menu.tscn"
const SPECIAL_LEVEL_SELECT := "res://Special Main Scene/SpecialLevelSelect.tscn" # <--- Tạo file này sau

func _ready():

	# START
	$"StartRoot/Start-BT".pressed.connect(
		func(): animate_button_down($StartRoot)
	)
	$"StartRoot/Start-BT".released.connect(
		func():
			animate_button_up($StartRoot)
			_on_start_bt_up()
	)

	# LEVEL SELECT
	$LevelRoot/LevelSelectBt.pressed.connect(
		func(): animate_button_down($LevelRoot)
	)
	$LevelRoot/LevelSelectBt.released.connect(
		func():
			animate_button_up($LevelRoot)
			_on_level_select_bt_up()
	)

	# QUIT
	$"QuitRoot/Quit-BT".pressed.connect(
		func(): animate_button_down($QuitRoot)
	)
	$"QuitRoot/Quit-BT".released.connect(
		func():
			animate_button_up($QuitRoot)
			_on_quit_bt_up()
	)

	# TROLL 😈
	$"TrollRoot/Troll-Bt".pressed.connect(
		func(): animate_button_down($TrollRoot)
	)
	$"TrollRoot/Troll-Bt".released.connect(
		func():
			animate_button_up($TrollRoot)
			_on_troll_bt_up()
	)

	# Nhạc
	var current_path := get_tree().current_scene.scene_file_path
	if current_path == SPECIAL_SCENE:
		AudioController.play_special_music()
	else:
		AudioController.play_main_music()


# --- XỬ LÝ NÚT START ---
func _on_start_bt_down():
	animate_button_down($"StartRoot/Start-BT")

func _on_start_bt_up():
	animate_button_up($"StartRoot/Start-BT")
	$"/root/AudioController".play_click()
	
	# 1. Kiểm tra Death Limit (Chung cho cả 2 chế độ)
	if not GameManager.can_player_die():
		show_death_limit_blocked_message()
		return
	
	# 2. Kiểm tra đang ở Menu nào để hành động tương ứng
	var current_path := get_tree().current_scene.scene_file_path
	
	if current_path == SPECIAL_SCENE:
		# --- CHẾ ĐỘ SPECIAL ---
		# Start game = Luôn bắt đầu từ Level 1 + Có Intro kể chuyện
		print("MAIN: Bắt đầu Special Mode!")
		GameManager.start_special_level(1) 
		
	else:
		# --- CHẾ ĐỘ MAIN THƯỜNG ---
		# Start game = Tiếp tục level cao nhất đã mở (Load Progress)
		var last_unlocked = GameManager.max_level_unlocked
		print("MAIN: Tiếp tục Main Mode tại level: ", last_unlocked)
		GameManager.go_to_level(last_unlocked)

# --- XỬ LÝ NÚT LEVEL SELECT ---
func _on_level_select_bt_down():
	animate_button_down($LevelRoot/LevelSelectBt)

func _on_level_select_bt_up():
	animate_button_up($LevelRoot/LevelSelectBt)
	$"/root/AudioController".play_click()
	
	if not GameManager.can_player_die():
		show_death_limit_blocked_message()
		return
		
	# Điều hướng sang bảng chọn level tương ứng
	var current_path := get_tree().current_scene.scene_file_path
	
	if current_path == SPECIAL_SCENE:
		# Mở bảng chọn level của Special (1-10)
		if ResourceLoader.exists(SPECIAL_LEVEL_SELECT):
			get_tree().change_scene_to_file.call_deferred(SPECIAL_LEVEL_SELECT)
		else:
			print("❌ Chưa tạo file SpecialLevelSelect.tscn!")
	else:
		# Mở bảng chọn level thường (1-50)
		get_tree().change_scene_to_file.call_deferred(MAIN_LEVEL_SELECT)

# --- XỬ LÝ NÚT TROLL (CHUYỂN ĐỔI MAIN <-> SPECIAL) ---


func _on_troll_bt_down():
	animate_button_down($"TrollRoot/Troll-Bt")

func _on_troll_bt_up():
	animate_button_up($"TrollRoot/Troll-Bt")
	$"/root/AudioController".play_click()	
	# ✨ HIỆU ỨNG ĐẶC BIỆT CHO NÚT TROLL ✨
	# 1. Screen shake rung lắc
	screen_shake(0.4, 15.0, 40.0)
	
	# 2. Flash đỏ nhẹ
	screen_flash(Color(1.0, 0.3, 0.3, 0.4), 0.3)
	
	# 3. Zoom effect cho button
	var zoom_tween = create_tween()
	zoom_tween.tween_property($TrollRoot, "scale", Vector2(1.2, 1.2), 0.1)
	zoom_tween.tween_property($TrollRoot, "scale", Vector2.ONE, 0.15)
	
	# 4. Chờ một chút rồi mới chuyển scene (cho hiệu ứng chạy xong)
	await get_tree().create_timer(0.4).timeout
	_toggle_main_special_scene()

func _toggle_main_special_scene():
	var current_scene := get_tree().current_scene
	if not current_scene: return

	var current_path := current_scene.scene_file_path
	var next_scene := ""

	if current_path == MAIN_SCENE:
		next_scene = SPECIAL_SCENE
	elif current_path == SPECIAL_SCENE:
		next_scene = MAIN_SCENE
	else:
		next_scene = MAIN_SCENE # Mặc định về Main nếu lạc trôi

	if ResourceLoader.exists(next_scene):
		get_tree().change_scene_to_file.call_deferred(next_scene)
	else:
		push_error("❌ Scene not found: " + next_scene)

# --- CÁC HÀM PHỤ TRỢ KHÁC (Quit, Animation, Popup) GIỮ NGUYÊN ---
func _on_quit_bt_down():
	animate_button_down($"QuitRoot/Quit-BT")

func _on_quit_bt_up():
	animate_button_up($"QuitRoot/Quit-BT")
	$"/root/AudioController".play_click()
	get_tree().quit()

func animate_button_down(root: Node2D):
	if not is_instance_valid(root): return
	
	if tween: tween.kill()
	tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(root, "scale", Vector2(0.9, 0.9), 0.1)


func animate_button_up(root: Node2D):
	if not is_instance_valid(root): return
	
	if tween: tween.kill()
	tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(root, "scale", Vector2.ONE, 0.15)

# --- SCREEN SHAKE EFFECT ---
func screen_shake(duration: float = 0.3, intensity: float = 10.0, frequency: float = 30.0):
	"""Tạo hiệu ứng rung màn hình - shake toàn bộ scene"""
	var original_position = position
	var elapsed = 0.0
	
	# Tạo shake bằng timer
	var shake_timer = Timer.new()
	shake_timer.wait_time = 1.0 / frequency
	shake_timer.one_shot = false
	add_child(shake_timer)
	
	var shake_callable = func():
		elapsed += shake_timer.wait_time
		if elapsed >= duration:
			position = original_position
			shake_timer.stop()
			shake_timer.queue_free()
		else:
			var progress = 1.0 - (elapsed / duration)
			var shake_amount = intensity * progress
			position = original_position + Vector2(
				randf_range(-shake_amount, shake_amount),
				randf_range(-shake_amount, shake_amount)
			)
	
	shake_timer.timeout.connect(shake_callable)
	shake_timer.start()

func screen_flash(color: Color = Color(1, 0, 0, 0.3), duration: float = 0.2):
	"""Tạo hiệu ứng flash màn hình"""
	var flash = ColorRect.new()
	flash.color = color
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	var canvas = CanvasLayer.new()
	canvas.layer = 150
	canvas.add_child(flash)
	add_child(canvas)
	
	var flash_tween = create_tween()
	flash_tween.tween_property(flash, "modulate:a", 0.0, duration)
	flash_tween.tween_callback(func(): canvas.queue_free())


# Keep old functions for compatibility (but they won't be called)
func _on_quit_bt_pressed() -> void:
	pass

func _on_start_bt_pressed() -> void:
	pass

func _on_level_select_bt_pressed() -> void:
	pass

func _on_troll_bt_pressed() -> void:
	pass # Replace with function body.

# ✅ HIỆN THÔNG BÁO DEATH LIMIT CHẶN GAME
func show_death_limit_blocked_message():
	# Tạo popup thông báo
	var popup_layer = CanvasLayer.new()
	popup_layer.layer = 200
	popup_layer.name = "BlockedPopup"
	add_child(popup_layer)
	
	# Background overlay
	var overlay = ColorRect.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0, 0, 0, 0.8)
	popup_layer.add_child(overlay)
	
	# Message panel
	var panel = Panel.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.offset_left = -200
	panel.offset_right = 200
	panel.offset_top = -120
	panel.offset_bottom = 120
	
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.15, 0.15, 0.25, 0.95)
	panel_style.corner_radius_top_left = 15
	panel_style.corner_radius_top_right = 15
	panel_style.corner_radius_bottom_left = 15
	panel_style.corner_radius_bottom_right = 15
	panel_style.border_width_left = 3
	panel_style.border_width_right = 3
	panel_style.border_width_top = 3
	panel_style.border_width_bottom = 3
	panel_style.border_color = Color(1.0, 0.3, 0.3, 1.0)
	panel.add_theme_stylebox_override("panel", panel_style)
	overlay.add_child(panel)
	
	# Skull icon
	var skull_label = Label.new()
	skull_label.text = "💀"
	skull_label.add_theme_font_size_override("font_size", 40)
	skull_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	skull_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	skull_label.offset_top = 15
	skull_label.offset_bottom = 55
	skull_label.offset_left = -25
	skull_label.offset_right = 25
	panel.add_child(skull_label)
	
	# Title
	var title_label = Label.new()
	title_label.text = "GAME BLOCKED!"
	title_label.add_theme_font_size_override("font_size", 20)
	title_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3, 1.0))
	title_label.add_theme_color_override("font_outline_color", Color.BLACK)
	title_label.add_theme_constant_override("outline_size", 2)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	title_label.offset_top = 55
	title_label.offset_bottom = 80
	title_label.offset_left = -150
	title_label.offset_right = 150
	panel.add_child(title_label)
	
	# Message
	var death_manager = GameManager.get_death_limit_manager()
	var time_data = death_manager.get_time_until_reset() if death_manager else {"hours": 0, "minutes": 0}
	
	var message_label = Label.new()
	message_label.text = "You've used all 50 lives today!\nCome back tomorrow to play again.\n\nReset in: %02d:%02d" % [time_data.hours, time_data.minutes]
	message_label.add_theme_font_size_override("font_size", 14)
	message_label.add_theme_color_override("font_color", Color.WHITE)
	message_label.add_theme_color_override("font_outline_color", Color.BLACK)
	message_label.add_theme_constant_override("outline_size", 1)
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	message_label.offset_left = 20
	message_label.offset_right = -20
	message_label.offset_top = 85
	message_label.offset_bottom = -50
	panel.add_child(message_label)
	
	# OK button
	var ok_button = Button.new()
	ok_button.text = "OK"
	ok_button.add_theme_font_size_override("font_size", 16)
	ok_button.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	ok_button.offset_left = -40
	ok_button.offset_right = 40
	ok_button.offset_top = -40
	ok_button.offset_bottom = -10
	ok_button.pressed.connect(_close_blocked_popup.bind(popup_layer))
	panel.add_child(ok_button)
	
	print("🚫 Game blocked - Death limit reached!")

func _close_blocked_popup(popup_layer: CanvasLayer):
	if is_instance_valid(popup_layer):
		popup_layer.queue_free()
	print("✅ Blocked popup closed")
