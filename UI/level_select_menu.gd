extends Control

@onready var grid_container = $VBoxContainer/GridContainer
@onready var back_button = $VBoxContainer/HBoxContainer/BackButton
@onready var reset_button = $VBoxContainer/HBoxContainer/ResetButton
@onready var title = $VBoxContainer/Title

const MAX_LEVELS = 11
var tween: Tween

func _ready():
	setup_ui()
	create_level_buttons()
	connect_signals()

func setup_ui():
	title.text = "SELECT LEVEL"

func create_level_buttons():
	# Setup TouchScreenButtons có sẵn trong scene
	for i in range(1, MAX_LEVELS + 1):
		var button_path = "VBoxContainer/GridContainer/Level" + str(i) + "Button"
		var button = get_node_or_null(button_path) as TouchScreenButton
		
		if button:
			setup_level_button(button, i)

func setup_level_button(button: TouchScreenButton, level_num: int):
	var is_unlocked = GameManager.is_level_unlocked(level_num)
	
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
		var lock_texture
		if lock_texture:
			button.texture_normal = lock_texture
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
	create_level_buttons()
