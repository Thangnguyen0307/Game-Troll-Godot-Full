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

@export_group("Page Button Text")
@export_enum("Range (1-10)", "Page Number", "Vietnamese", "No Text") var label_style: int = 0  ## Kiểu hiển thị text
@export var label_font_size: int = 18  ## Kích thước chữ
@export var label_color: Color = Color.WHITE  ## Màu chữ

@export_group("Navigation")
@export var show_arrows: bool = true  ## Hiển thị mũi tên ◀ ▶
@export var enable_swipe: bool = true  ## Bật vuốt trái/phải
@export var swipe_threshold: float = 50.0  ## Độ nhạy vuốt
@export var arrow_size: float = 80.0  ## Kích thước mũi tên
@export var arrow_spacing: float = 200.0  ## Khoảng cách giữa 2 mũi tên
@export_enum("Below Grid", "Above Grid", "Sides of Grid") var arrow_position: int = 0  ## Vị trí mũi tên
@export var use_arrow_images: bool = true  ## Dùng hình ảnh (Left.png/Right.png) thay vì text

@onready var grid_container = $VBoxContainer/GridContainer
@onready var back_button = $VBoxContainer/HBoxContainer/BackButton
@onready var reset_button = $VBoxContainer/HBoxContainer/ResetButton
@onready var title = $VBoxContainer/Title
@onready var page_container = $VBoxContainer/PageContainer

var tween: Tween
var current_page = 1
var total_pages = 0
var page_buttons = []  # Array chứa các page buttons được tạo động

# Navigation
var prev_arrow: Control
var next_arrow: Control
var swipe_start_position = Vector2.ZERO
var is_swiping = false

func _ready():
	setup_ui()
	create_page_buttons()
	create_arrows()  # ✅ Thêm mũi tên
	create_level_buttons()
	connect_signals()
	update_page_display()
	update_arrows()  # ✅ Update arrow visibility

func setup_ui():
	title.text = "SELECT LEVEL"
	total_pages = int(ceil(float(max_levels) / levels_per_page))

func _input(event):
	# ✅ Swipe detection
	if not enable_swipe:
		return
	
	if event is InputEventScreenTouch:
		if event.pressed:
			swipe_start_position = event.position
			is_swiping = true
		else:
			if is_swiping:
				var swipe_distance = event.position - swipe_start_position
				
				# Vuốt TRÁI → Next
				if swipe_distance.x < -swipe_threshold and abs(swipe_distance.x) > abs(swipe_distance.y):
					go_next_page()
				# Vuốt PHẢI → Previous
				elif swipe_distance.x > swipe_threshold and abs(swipe_distance.x) > abs(swipe_distance.y):
					go_prev_page()
			
			is_swiping = false

func create_arrows():
	# ✅ Tạo mũi tên đơn giản
	if not show_arrows:
		return
	
	var vbox = grid_container.get_parent()
	
	# Chọn vị trí dựa trên arrow_position
	match arrow_position:
		0:  # Below Grid (Dưới grid) - MẶC ĐỊNH
			create_arrows_horizontal(vbox, grid_container.get_index() + 1)
		1:  # Above Grid (Trên grid)
			create_arrows_horizontal(vbox, grid_container.get_index())
		2:  # Sides of Grid (Hai bên grid) - ĐẶC BIỆT
			create_arrows_sides()

func create_arrows_horizontal(parent: VBoxContainer, insert_index: int):
	"""Tạo arrows ngang (◀     ▶)"""
	var arrow_container = HBoxContainer.new()
	arrow_container.alignment = BoxContainer.ALIGNMENT_CENTER
	arrow_container.add_theme_constant_override("separation", int(arrow_spacing))
	
	parent.add_child(arrow_container)
	parent.move_child(arrow_container, insert_index)
	
	# ◀ Previous
	prev_arrow = create_arrow("◀")
	arrow_container.add_child(prev_arrow)
	
	# ▶ Next
	next_arrow = create_arrow("▶")
	arrow_container.add_child(next_arrow)

func create_arrows_sides():
	"""Tạo arrows ở 2 bên grid (◀ [Grid] ▶)"""
	# Wrap GridContainer trong HBoxContainer
	var wrapper = HBoxContainer.new()
	wrapper.alignment = BoxContainer.ALIGNMENT_CENTER
	wrapper.add_theme_constant_override("separation", 20)
	
	var vbox = grid_container.get_parent()
	var grid_index = grid_container.get_index()
	
	# Remove grid từ VBox
	vbox.remove_child(grid_container)
	
	# Thêm wrapper vào VBox
	vbox.add_child(wrapper)
	vbox.move_child(wrapper, grid_index)
	
	# ◀ Previous
	prev_arrow = create_arrow("◀")
	wrapper.add_child(prev_arrow)
	
	# GridContainer
	wrapper.add_child(grid_container)
	
	# ▶ Next
	next_arrow = create_arrow("▶")
	wrapper.add_child(next_arrow)

func create_arrow(text: String) -> Control:
	var container = Control.new()
	container.custom_minimum_size = Vector2(arrow_size, arrow_size)
	
	if use_arrow_images:
		# ✅ Dùng hình ảnh Left.png / Right.png
		var texture_path = "res://Touch_Controls/Left.png" if text == "◀" else "res://Touch_Controls/Right.png"
		var texture = load(texture_path)
		
		if texture:
			# Dùng TextureRect để hiển thị hình
			var texture_rect = TextureRect.new()
			texture_rect.texture = texture
			texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			texture_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
			texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
			container.add_child(texture_rect)
	else:
		# Background màu (nếu không dùng hình)
		var bg = ColorRect.new()
		bg.color = Color(0.2, 0.5, 0.8, 0.9)
		bg.set_anchors_preset(Control.PRESET_FULL_RECT)
		container.add_child(bg)
		
		# Label text
		var label = Label.new()
		label.text = text
		label.set_anchors_preset(Control.PRESET_FULL_RECT)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", int(arrow_size * 0.6))
		label.add_theme_color_override("font_color", Color.WHITE)
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		container.add_child(label)
	
	# TouchScreenButton
	var touch_button = TouchScreenButton.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(arrow_size, arrow_size)
	touch_button.shape = shape
	touch_button.position = Vector2(arrow_size / 2, arrow_size / 2)
	container.add_child(touch_button)
	
	# Connect
	if text == "◀":
		touch_button.pressed.connect(_on_prev_pressed)
		touch_button.released.connect(_on_prev_released)
	else:
		touch_button.pressed.connect(_on_next_pressed)
		touch_button.released.connect(_on_next_released)
	
	return container

func _on_prev_pressed():
	if prev_arrow and current_page > 1:
		animate_button_down(prev_arrow)

func _on_prev_released():
	if prev_arrow:
		animate_button_up(prev_arrow)
	go_prev_page()

func _on_next_pressed():
	if next_arrow and current_page < total_pages:
		animate_button_down(next_arrow)

func _on_next_released():
	if next_arrow:
		animate_button_up(next_arrow)
	go_next_page()

func go_prev_page():
	if current_page > 1:
		change_to_page(current_page - 1)

func go_next_page():
	if current_page < total_pages:
		change_to_page(current_page + 1)

func change_to_page(new_page: int):
	current_page = new_page
	$"/root/AudioController".play_click()
	create_level_buttons()
	update_page_display()
	update_arrows()

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
		
		# Load texture trước
		# Option 1: Dùng icon riêng cho page buttons
		# var texture_path = "res://UI/icons/page_" + str(page_num) + ".png"
		
		# Option 2: Dùng icon của level đầu tiên (hiện tại) - ĐANG DÙNG
		var texture_path = "res://Pixel Adventure 1/Free/Menu/Levels/" + str(start_level).pad_zeros(2) + ".png"
		
		# Option 3: Dùng cùng 1 icon cho tất cả pages
		# var texture_path = "res://UI/icons/level_button.png"
		
		var texture = load(texture_path)
		if texture:
			var texture_size = texture.get_size()
			var scaled_size = texture_size * page_button_scale
			button_container.custom_minimum_size = scaled_size
			
			# Tạo TextureRect để hiển thị hình (scale được)
			var texture_rect = TextureRect.new()
			texture_rect.texture = texture
			texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			texture_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
			texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
			button_container.add_child(texture_rect)
			
			# Tạo TouchScreenButton phủ lên toàn bộ container
			var page_button = TouchScreenButton.new()
			var shape = RectangleShape2D.new()
			shape.size = scaled_size
			page_button.shape = shape
			page_button.position = scaled_size / 2  # Center của shape
			button_container.add_child(page_button)
			
			# Tạo Label hiển thị range - CÓ THỂ THAY ĐỔI TEXT Ở ĐÂY
			var label = Label.new()
			
			# Chọn text dựa trên label_style từ Inspector
			match label_style:
				0:  # Range (1-10)
					label.text = str(start_level) + "-" + str(end_level)
				1:  # Page Number
					label.text = str(page_num)
				2:  # Vietnamese
					label.text = "Trang " + str(page_num)
				3:  # No Text
					label.text = ""
			
			label.set_anchors_preset(Control.PRESET_FULL_RECT)
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			label.add_theme_color_override("font_color", label_color)
			label.add_theme_font_size_override("font_size", label_font_size)
			label.mouse_filter = Control.MOUSE_FILTER_IGNORE
			button_container.add_child(label)
			
			# Connect signals
			var page_index = page_num
			page_button.pressed.connect(func(): _on_page_button_pressed(page_index, button_container))
			page_button.released.connect(func(): _on_page_button_released(page_index, button_container))
			
			page_container.add_child(button_container)
			page_buttons.append(button_container)
			
			# Thêm spacer giữa các buttons (trừ button cuối)
			if page_num < total_pages:
				var spacer = Control.new()
				spacer.custom_minimum_size = Vector2(page_spacing, 0)
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
	tween.tween_property(button, "scale", Vector2(0.9, 0.9), 0.1)  # ✅ FIX: Dùng Vector2 cố định

func animate_button_up(button: Node):
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.1)  # ✅ FIX: Dùng Vector2 cố định

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
	get_tree().change_scene_to_file.call_deferred("res://Scene Main Start/main.tscn")

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
		change_to_page(target_page)
	else:
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

func update_arrows():
	# ✅ Ẩn/hiện arrows
	if not show_arrows:
		return
	
	if prev_arrow:
		prev_arrow.modulate.a = 1.0 if current_page > 1 else 0.3
	if next_arrow:
		next_arrow.modulate.a = 1.0 if current_page < total_pages else 0.3

# Compatibility functions (không dùng nữa nhưng giữ để tránh errors từ scene)
func _on_page1_pressed():
	pass

func _on_page1_released():
	pass

func _on_page2_pressed():
	pass

func _on_page2_released():
	pass
