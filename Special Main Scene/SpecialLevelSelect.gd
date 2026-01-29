extends Control

# --- CẤU HÌNH CHO SPECIAL MODE ---
@export_group("Level Settings")
@export var max_levels: int = 10  # Mặc định 10 level cho Special
@export var levels_per_page: int = 10

@export_group("Navigation")
@export var show_arrows: bool = false # Tắt mũi tên vì chỉ có 1 trang
@export var enable_swipe: bool = false # Tắt vuốt

# Các biến UI References (Giữ nguyên cấu trúc cũ)
@onready var grid_container = $VBoxContainer/GridContainer
@onready var back_button = $VBoxContainer/HBoxContainer/BackButton
@onready var reset_button = $VBoxContainer/HBoxContainer/ResetButton
@onready var title = $VBoxContainer/Title

var tween: Tween
var current_page = 1

func _ready():
	setup_ui()
	create_level_buttons()
	connect_signals()
	
	# Ẩn nút Reset vì Special Mode không cần reset progress
	if reset_button:
		reset_button.visible = false

func setup_ui():
	title.text = "SPECIAL ZONES" # Đổi tên tiêu đề cho ngầu
	
	# Nếu bạn muốn nhạc riêng cho menu này
	# AudioController.play_special_music()

func create_level_buttons():
	# Vì Special Mode thường chỉ có 1 trang 10 level, ta xử lý đơn giản hơn
	var start_level = 1
	var end_level = max_levels
	
	for i in range(1, 11):
		# Tìm nút trong GridContainer (Level1Button, Level2Button...)
		var button_path = "VBoxContainer/GridContainer/Level" + str(i) + "Button"
		var button = get_node_or_null(button_path) as TouchScreenButton
		
		if button:
			if i <= max_levels:
				setup_level_button(button, i)
				button.visible = true
			else:
				button.visible = false

func setup_level_button(button: TouchScreenButton, level_num: int):
	# --- THAY ĐỔI 1: LUÔN MỞ KHÓA (HOẶC LOGIC RIÊNG) ---
	# Special level thường mở hết để người chơi thử thách
	# Nếu bạn muốn khóa, hãy tạo biến riêng trong GameManager như `special_level_unlocked`
	var is_unlocked = true 
	
	# Load hình ảnh (Bạn có thể đổi đường dẫn folder icon khác nếu muốn)
	var texture_path = "res://Pixel Adventure 1/Free/Menu/Levels/" + str(level_num).pad_zeros(2) + ".png"
	var texture = load(texture_path)
	if texture:
		button.texture_normal = texture
	
	# Reset kết nối cũ để tránh lỗi duplicate signal
	if button.pressed.get_connections().size() > 0:
		for connection in button.pressed.get_connections():
			button.pressed.disconnect(connection.callable)
	if button.released.get_connections().size() > 0:
		for connection in button.released.get_connections():
			button.released.disconnect(connection.callable)
	
	if is_unlocked:
		button.modulate = Color(1, 0.5, 0.5) # --- THAY ĐỔI 2: ĐỔI MÀU ĐỎ NHẸ ĐỂ BÁO HIỆU KHÓ ---
		button.pressed.connect(func(): animate_button_down(button))
		button.released.connect(func(): _on_special_level_released(level_num, button))
	else:
		button.modulate = Color.GRAY

# --- XỬ LÝ KHI CHỌN LEVEL ---
func _on_special_level_released(level_number: int, button: TouchScreenButton):
	animate_button_up(button)
	$"/root/AudioController".play_click()
	
	# --- KIỂM TRA LEVEL CÓ TỒN TẠI KHÔNG ---
	if not is_level_available(level_number):
		show_unavailable_message()
		return
	
	# --- KIỂM TRA DEATH LIMIT ---
	if not GameManager.can_player_die():
		GameManager._show_death_limit_block_message()
		return

	# --- GỌI HÀM START_SPECIAL_LEVEL ---
	print("Vào Special Level: ", level_number)
	GameManager.start_special_level(level_number)

func is_level_available(level_number: int) -> bool:
	"""Kiểm tra level có scene file không"""
	var path = "res://All_Level/Special_Level/Special_Level_" + str(level_number) + "/Special_Level_" + str(level_number) + ".tscn"
	return ResourceLoader.exists(path)

func show_unavailable_message():
	
	# Tạo CanvasLayer để overlay lên toàn màn hình
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100  # Layer cao để hiện trên cùng
	
	# Background tối full screen
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.85)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Tạo popup label center
	var popup = Label.new()
	popup.text = "UNAVAILABLE"
	
	# Set anchors cho center
	popup.set_anchors_preset(Control.PRESET_CENTER)
	popup.offset_left = -300
	popup.offset_top = -50
	popup.offset_right = 300
	popup.offset_bottom = 50
	popup.grow_horizontal = Control.GROW_DIRECTION_BOTH
	popup.grow_vertical = Control.GROW_DIRECTION_BOTH
	
	popup.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	popup.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	# Style - Màu đỏ sáng pixel game
	popup.add_theme_font_size_override("font_size", 56)
	popup.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2, 1))  # Đỏ sáng
	popup.add_theme_color_override("font_outline_color", Color(0.1, 0, 0, 1))  # Viền đen đỏ
	popup.add_theme_constant_override("outline_size", 6)
	
	# Thêm vào CanvasLayer
	canvas_layer.add_child(bg)
	canvas_layer.add_child(popup)
	
	# Thêm CanvasLayer vào root
	get_tree().root.add_child(canvas_layer)
	
	# Animation: Hiện -> Dừng -> Fade đi
	popup.modulate.a = 0
	bg.modulate.a = 0
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(popup, "modulate:a", 1.0, 0.4)  # Fade in chậm hơn
	tween.tween_property(bg, "modulate:a", 1.0, 0.4)
	tween.set_parallel(false)
	tween.tween_interval(3.5)  # Hiển thị 3.5s thay vì 2s
	tween.set_parallel(true)
	tween.tween_property(popup, "modulate:a", 0.0, 0.6)  # Fade out chậm hơn
	tween.tween_property(bg, "modulate:a", 0.0, 0.6)
	tween.set_parallel(false)
	tween.tween_callback(func():
		canvas_layer.queue_free()  # Xóa cả CanvasLayer
	)

# --- XỬ LÝ NÚT BACK ---
func connect_signals():
	var back_touch_button = $"VBoxContainer/HBoxContainer/BackButton/TouchScreenButton"
	if back_touch_button:
		back_touch_button.pressed.connect(func(): animate_button_down(back_button))
		back_touch_button.released.connect(_on_back_button_released)

func _on_back_button_released():
	animate_button_up(back_button)
	$"/root/AudioController".play_click()
	
	# --- THAY ĐỔI 5: QUAY VỀ SPECIAL MENU ---
	get_tree().change_scene_to_file.call_deferred("res://Special Main Scene/special_main.tscn")

# --- HIỆU ỨNG ANIMATION (Giữ nguyên) ---
func animate_button_down(button: Node):
	if tween:
		tween.kill()
	tween = create_tween()
	
	# Xử lý khác nhau cho Control và Node2D
	if button is Control:
		# Nếu là Button trong container với TouchScreenButton child, animate child thay vì parent
		if button is Button and button.get_child_count() > 0:
			var touch_button = button.get_child(0)
			if touch_button is Node2D:
				animate_button_down(touch_button)  # Recursive call cho TouchScreenButton
				return
		
		# Control nodes thông thường - dùng pivot_offset
		button.pivot_offset = button.size / 2
		tween.tween_property(button, "scale", Vector2(0.9, 0.9), 0.1)
	elif button is Node2D:
		# Node2D (TouchScreenButton) - lưu base scale và scale từ center
		if not button.has_meta("base_scale"):
			button.set_meta("base_scale", button.scale)
		if not button.has_meta("base_position"):
			button.set_meta("base_position", button.position)
		
		var base_scale = button.get_meta("base_scale")
		var base_pos = button.get_meta("base_position")
		var target_scale = base_scale * 0.9
		
		# Tính toán position offset để giữ center cố định
		var texture_size = Vector2.ZERO
		if button.texture_normal:
			texture_size = button.texture_normal.get_size()
		var center_offset = texture_size * base_scale * 0.05  # 0.05 = (1.0 - 0.9) / 2
		
		tween.parallel().tween_property(button, "scale", target_scale, 0.1)
		tween.parallel().tween_property(button, "position", base_pos + center_offset, 0.1)

func animate_button_up(button: Node):
	if tween:
		tween.kill()
	tween = create_tween()
	
	# Xử lý khác nhau cho Control và Node2D
	if button is Control:
		# Nếu là Button trong container với TouchScreenButton child, animate child thay vì parent
		if button is Button and button.get_child_count() > 0:
			var touch_button = button.get_child(0)
			if touch_button is Node2D:
				animate_button_up(touch_button)  # Recursive call cho TouchScreenButton
				return
		
		# Control nodes thông thường - dùng pivot_offset
		button.pivot_offset = button.size / 2
		tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.1)
	elif button is Node2D:
		# Node2D (TouchScreenButton) - restore về base scale và position
		if not button.has_meta("base_scale"):
			button.set_meta("base_scale", button.scale)
		if not button.has_meta("base_position"):
			button.set_meta("base_position", button.position)
		
		var base_scale = button.get_meta("base_scale")
		var base_pos = button.get_meta("base_position")
		
		tween.parallel().tween_property(button, "scale", base_scale, 0.1)
		tween.parallel().tween_property(button, "position", base_pos, 0.1)
