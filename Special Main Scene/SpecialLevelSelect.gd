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
	
	# --- THAY ĐỔI 3: KIỂM TRA DEATH LIMIT ---
	if not GameManager.can_player_die():
		# Gọi hàm hiện thông báo lỗi từ Main (nếu có) hoặc tự xử lý
		# Vì script này độc lập, ta gọi qua GameManager để hiện popup nếu cần
		GameManager._show_death_limit_block_message()
		return

	# --- THAY ĐỔI 4: GỌI HÀM START_SPECIAL_LEVEL ---
	print("Vào Special Level: ", level_number)
	GameManager.start_special_level(level_number)

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
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_property(button, "scale", Vector2(0.9, 0.9), 0.1)

func animate_button_up(button: Node):
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.1)
