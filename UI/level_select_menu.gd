extends Control

# Export variables - Có thể chỉnh sửa trong Inspector
@export_group("Level Settings")
@export var max_levels: int = 20  ## Tổng số levels trong game
@export var levels_per_page: int = 10  ## Số levels hiển thị mỗi trang

@export_group("Page Button Settings")
@export var page_button_scale: Vector2 = Vector2(1.0, 1.0)  ## Scale của page buttons
@export var page_spacing: float = 30.0  ## Khoảng cách giữa các page buttons
@export var active_page_color: Color = Color.WHITE  ## Màu page button đang active
@export var inactive_page_color: Color = Color(0.6, 0.6, 0.6, 1.0)  ## Màu page buttons không active

@onready var grid_container = $VBoxContainer/GridContainer
@onready var back_button = $VBoxContainer/HBoxContainer/BackButton
@onready var reset_button = $VBoxContainer/HBoxContainer/ResetButton
@onready var title = $VBoxContainer/Title
@onready var page_container = $VBoxContainer/PageContainer

var tween: Tween
var current_page = 1
var total_pages = 0
var page_buttons = []  # Array chứa các page buttons được tạo động

func _ready():
	setup_ui()
	create_page_buttons()
	create_level_buttons()
	connect_signals()
	update_page_display()

func setup_ui():
	title.text = "SELECT LEVEL"
	total_pages = int(ceil(float(max_levels) / levels_per_page))

func create_page_buttons():
	# Xóa tất cả page buttons cũ trong PageContainer
	for child in page_container.get_children():
		child.queue_free()
	
	page_buttons.clear()
	
	# Tạo page buttons động dựa trên max_levels
	for page_num in range(1, total_pages + 1):
		var start_level = (page_num - 1) * levels_per_page + 1
		var end_level = min(page_num * levels_per_page, max_levels)
		
		# Tạo Control wrapper để có layout properties
		var button_container = Control.new()
		button_container.custom_minimum_size = Vector2(64, 64) * page_button_scale  # Kích thước mặc định
		
		# Tạo TouchScreenButton bên trong
		var page_button = TouchScreenButton.new()
		
		# Load texture từ folder (dùng icon của level đầu tiên trong page)
		var texture_path = "res://Pixel Adventure 1/Free/Menu/Levels/" + str(start_level).pad_zeros(2) + ".png"
		var texture = load(texture_path)
		if texture:
			page_button.texture_normal = texture
			# Cập nhật kích thước container dựa trên texture
			var texture_size = texture.get_size()
			button_container.custom_minimum_size = texture_size * page_button_scale
		
		# Tạo Label hiển thị range
		var label = Label.new()
		label.text = str(start_level) + "-" + str(end_level)
		label.set_anchors_preset(Control.PRESET_FULL_RECT)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_color_override("font_color", Color.WHITE)
		label.add_theme_font_size_override("font_size", 18)
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Label không chặn clicks
		page_button.add_child(label)
		
		# Thêm TouchScreenButton vào container
		button_container.add_child(page_button)
		
		# Connect signals với closure để capture page_num
		var page_index = page_num
		page_button.pressed.connect(func(): _on_page_button_pressed(page_index, button_container))
		page_button.released.connect(func(): _on_page_button_released(page_index, button_container))
		
		page_container.add_child(button_container)
		page_buttons.append(button_container)  # Lưu container, không phải button
		
		# Thêm spacer giữa các buttons (trừ button cuối)
		if page_num < total_pages:
			var spacer = Control.new()
			spacer.custom_minimum_size = Vector2(page_spacing, 0)
			spacer.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			page_container.add_child(spacer)

func create_level_buttons():
	# Tính level range cho trang hiện tại
	var start_level = (current_page - 1) * levels_per_page + 1
	var end_level = min(current_page * levels_per_page, max_levels)
	
	# Setup TouchScreenButtons có sẵn trong scene (chỉ có 10 buttons)
	for i in range(1, 11):
		var button_path = "VBoxContainer/GridContainer/Level" + str(i) + "Button"
		var button = get_node_or_null(button_path) as TouchScreenButton
		
		if button:
			var actual_level = start_level + i - 1
			if actual_level <= end_level:
				setup_level_button(button, actual_level)
				button.visible = true
			else:
				button.visible = false

func setup_level_button(button: TouchScreenButton, level_num: int):
	var is_unlocked = GameManager.is_level_unlocked(level_num)
	
	# Thay đổi texture theo level number
	var texture_path = "res://Pixel Adventure 1/Free/Menu/Levels/" + str(level_num).pad_zeros(2) + ".png"
	var texture = load(texture_path)
	if texture:
		button.texture_normal = texture
	
	# Disconnect existing signals
	if button.pressed.get_connections().size() > 0:
		for connection in button.pressed.get_connections():
			button.pressed.disconnect(connection.callable)
	if button.released.get_connections().size() > 0:
		for connection in button.released.get_connections():
			button.released.disconnect(connection.callable)
	
	if is_unlocked:
		# Level unlocked
		button.modulate = Color.WHITE
		button.pressed.connect(func(): _on_level_button_pressed(button))
		button.released.connect(func(): _on_level_button_released(level_num, button))
	else:
		# Level locked
		button.modulate = Color.GRAY

# Helper functions không cần thiết nữa - buttons đã được tạo trong scene

func connect_signals():
	# Connect TouchScreenButton signals for back and reset buttons
	var back_touch_button = $"VBoxContainer/HBoxContainer/BackButton/TouchScreenButton"
	var reset_touch_button = $"VBoxContainer/HBoxContainer/ResetButton/TouchScreenButton"
	
	if back_touch_button:
		back_touch_button.pressed.connect(_on_back_button_pressed)
		back_touch_button.released.connect(_on_back_button_released)
	if reset_touch_button:
		reset_touch_button.pressed.connect(_on_reset_button_pressed)
		reset_touch_button.released.connect(_on_reset_button_released)
	
	# Listen for level unlocks
	GameManager.level_unlocked.connect(_on_level_unlocked)

func animate_button_down(button: Node):
	if tween:
		tween.kill()
	tween = create_tween()
	var original_scale = button.scale
	tween.tween_property(button, "scale", original_scale * 0.9, 0.1)

func animate_button_up(button: Node):
	if tween:
		tween.kill()
	tween = create_tween()
	var original_scale = button.scale / 0.9  # Tính lại scale gốc
	tween.tween_property(button, "scale", original_scale, 0.1)

# Khi nhấn xuống level button
func _on_level_button_pressed(button: TouchScreenButton):
	animate_button_down(button)

# Khi thả level button
func _on_level_button_released(level_number: int, button: TouchScreenButton):
	animate_button_up(button)
	$"/root/AudioController".play_click()
	GameManager.go_to_level(level_number)

# Back button signals
func _on_back_button_pressed():
	animate_button_down(back_button)

func _on_back_button_released():
	animate_button_up(back_button)
	$"/root/AudioController".play_click()
	get_tree().change_scene_to_file("res://All_Level/Scene Main Start/main.tscn")

# Reset button signals  
func _on_reset_button_pressed():
	animate_button_down(reset_button)

func _on_reset_button_released():
	animate_button_up(reset_button)
	GameManager.max_level_unlocked = 1
	GameManager.current_level = 1
	GameManager.reset_death_count()  # Reset death count cùng với progress
	GameManager.save_progress()
	create_level_buttons()

# Keep old functions for compatibility (won't be used)
func _on_back_pressed():
	pass

func _on_reset_pressed():
	pass

func _on_level_unlocked(level_number: int):
	# Auto chuyển đến trang chứa level mới unlock
	var target_page = int((level_number - 1) / levels_per_page) + 1
	if target_page != current_page:
		current_page = target_page
		update_page_display()
	create_level_buttons()

# Page button handlers (dynamic)
func _on_page_button_pressed(page_num: int, container: Control):
	animate_button_down(container)

func _on_page_button_released(page_num: int, container: Control):
	animate_button_up(container)
	if current_page != page_num:
		current_page = page_num
		$"/root/AudioController".play_click()
		create_level_buttons()
		update_page_display()

func update_page_display():
	# Cập nhật UI cho page buttons và title
	var start_level = (current_page - 1) * levels_per_page + 1
	var end_level = min(current_page * levels_per_page, max_levels)
	
	title.text = "SELECT LEVEL (" + str(start_level) + "-" + str(end_level) + ")"
	
	# Highlight page button hiện tại
	for i in range(page_buttons.size()):
		if i + 1 == current_page:
			page_buttons[i].modulate = active_page_color
		else:
			page_buttons[i].modulate = inactive_page_color

# Compatibility functions (không dùng nữa nhưng giữ để tránh errors từ scene)
func _on_page1_pressed():
	pass

func _on_page1_released():
	pass

func _on_page2_pressed():
	pass

func _on_page2_released():
	pass
