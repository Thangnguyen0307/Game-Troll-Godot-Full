extends Control

@onready var grid_container = $VBoxContainer/GridContainer
@onready var back_button = $VBoxContainer/HBoxContainer/BackButton
@onready var reset_button = $VBoxContainer/HBoxContainer/ResetButton
@onready var title = $VBoxContainer/Title

# Page buttons từ scene
@onready var page1_button = $VBoxContainer/PageContainer/Page1Button
@onready var page2_button = $VBoxContainer/PageContainer/Page2Button

const MAX_LEVELS = 20
const LEVELS_PER_PAGE = 10
var tween: Tween
var current_page = 1  # 1 = levels 1-10, 2 = levels 11-20

func _ready():
	setup_ui()
	create_level_buttons()
	connect_signals()
	update_page_display()

func setup_ui():
	title.text = "SELECT LEVEL"

func create_level_buttons():
	# Tính level range cho trang hiện tại
	var start_level = (current_page - 1) * LEVELS_PER_PAGE + 1
	var end_level = min(current_page * LEVELS_PER_PAGE, MAX_LEVELS)
	
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
	var target_page = int((level_number - 1) / LEVELS_PER_PAGE) + 1
	if target_page != current_page:
		current_page = target_page
		update_page_display()
	create_level_buttons()

# Page button handlers
func _on_page1_pressed():
	if page1_button:
		animate_button_down(page1_button)

func _on_page1_released():
	if page1_button:
		animate_button_up(page1_button)
	if current_page != 1:
		current_page = 1
		$"/root/AudioController".play_click()
		create_level_buttons()
		update_page_display()

func _on_page2_pressed():
	if page2_button:
		animate_button_down(page2_button)

func _on_page2_released():
	if page2_button:
		animate_button_up(page2_button)
	if current_page != 2:
		current_page = 2
		$"/root/AudioController".play_click()
		create_level_buttons()
		update_page_display()

func update_page_display():
	# Cập nhật UI cho page buttons và title
	if page1_button and page2_button:
		if current_page == 1:
			page1_button.modulate = Color.WHITE
			page2_button.modulate = Color(0.6, 0.6, 0.6, 1.0)
			title.text = "SELECT LEVEL (1-10)"
		else:
			page1_button.modulate = Color(0.6, 0.6, 0.6, 1.0)
			page2_button.modulate = Color.WHITE
			title.text = "SELECT LEVEL (11-20)"
