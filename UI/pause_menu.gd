extends CanvasLayer

var is_sound_on = true
var tween: Tween
var background_overlay: ColorRect

func _ready():
	visible = false
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	create_background_overlay()
	setup_button_sizes()  # Thêm setup button sizes
	setup_button_signals()

func setup_button_sizes():
	"""Tăng kích thước buttons để fill vùng menu"""
	var buttons = [
		$"CenterContainer/VBoxContainer/ReplayButton",
		$"CenterContainer/VBoxContainer/HomeButton",
		$"CenterContainer/VBoxContainer/SoundButton",
		$"CenterContainer/VBoxContainer/Continue"
	]
	
	for button in buttons:
		if button:
			button.custom_minimum_size = Vector2(270, 65)  # Size compact như screenshot
			
			# Bật expand_icon và set kích thước icon lớn
			button.expand_icon = true
			button.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
			button.add_theme_constant_override("icon_max_width", 50)  # Icon width
			
			# Tăng font size cho text
			var font_size = 22  # Font size lớn hơn
			button.add_theme_font_size_override("font_size", font_size)
			
			# Update TouchScreenButton shape để match với button size mới
			var touch_button = button.get_child(0)
			if touch_button is TouchScreenButton:
				var new_shape = RectangleShape2D.new()
				new_shape.size = Vector2(270, 65)
				touch_button.shape = new_shape
				touch_button.position = Vector2(135, 32.5)  # Center của shape
				touch_button.scale = Vector2.ONE  # Reset scale về 1
	
	# Spacing nhỏ hơn giữa các buttons
	$CenterContainer/VBoxContainer.add_theme_constant_override("separation", 10)

func create_background_overlay():
	"""Tạo background tối mờ cho pause menu"""
	background_overlay = ColorRect.new()
	background_overlay.color = Color(0, 0, 0, 0.7)
	background_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	background_overlay.mouse_filter = Control.MOUSE_FILTER_PASS  # Để click xuyên qua
	background_overlay.z_index = -1  # Đặt phía sau
	add_child(background_overlay)

	move_child(background_overlay, 0)  # Đặt làm child đầu tiên

func show_menu():
	visible = true
	get_tree().paused = true
	
	# Đảm bảo CenterContainer hiển thị đúng
	$CenterContainer.modulate = Color.WHITE
	$CenterContainer.scale = Vector2.ONE

func hide_menu():
	visible = false
	get_tree().paused = false

func animate_button_down(button: Node):
	if button is Control:
		# Set pivot_offset để scale từ center
		button.pivot_offset = button.size / 2
	
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(button, "scale", Vector2(0.9, 0.9), 0.1)

func animate_button_up(button: Node):
	if button is Control:
		# Set pivot_offset để scale từ center
		button.pivot_offset = button.size / 2
	
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.15)

func setup_button_signals():
	# Get TouchScreenButton references
	var replay_touch = $"CenterContainer/VBoxContainer/ReplayButton/ReplayTouch"
	var home_touch = $"CenterContainer/VBoxContainer/HomeButton/home"
	var sound_touch = $"CenterContainer/VBoxContainer/SoundButton/Sound"
	var continue_touch = $"CenterContainer/VBoxContainer/Continue/Continue"
	
	# Disconnect existing pressed signals and connect new pressed/released signals
	if replay_touch:
		replay_touch.pressed.disconnect(_on_replay_button_pressed)
		replay_touch.pressed.connect(_on_replay_button_down)
		replay_touch.released.connect(_on_replay_button_up)
	
	if home_touch:
		home_touch.pressed.disconnect(_on_home_button_pressed)
		home_touch.pressed.connect(_on_home_button_down)
		home_touch.released.connect(_on_home_button_up)
	
	if sound_touch:
		sound_touch.pressed.disconnect(_on_sound_button_pressed)
		sound_touch.pressed.connect(_on_sound_button_down)
		sound_touch.released.connect(_on_sound_button_up)
	
	if continue_touch:
		continue_touch.pressed.disconnect(_on_continue_pressed)
		continue_touch.pressed.connect(_on_continue_button_down)
		continue_touch.released.connect(_on_continue_button_up)

# Continue button
func _on_continue_button_down():
	animate_button_down($"CenterContainer/VBoxContainer/Continue")

func _on_continue_button_up():
	animate_button_up($"CenterContainer/VBoxContainer/Continue")
	$"/root/AudioController".play_click()
	hide_menu()

# Replay button
func _on_replay_button_down():
	animate_button_down($"CenterContainer/VBoxContainer/ReplayButton")

func _on_replay_button_up():
	animate_button_up($"CenterContainer/VBoxContainer/ReplayButton")
	$"/root/AudioController".play_click()
	get_tree().paused = false
	get_tree().reload_current_scene()

# Home button
func _on_home_button_down():
	animate_button_down($"CenterContainer/VBoxContainer/HomeButton")

func _on_home_button_up():
	animate_button_up($"CenterContainer/VBoxContainer/HomeButton")
	$"/root/AudioController".play_click()
	get_tree().paused = false
	get_tree().change_scene_to_file.call_deferred("res://Scene Main Start/main.tscn")

# Sound button
func _on_sound_button_down():
	animate_button_down($"CenterContainer/VBoxContainer/SoundButton")

func _on_sound_button_up():
	animate_button_up($"CenterContainer/VBoxContainer/SoundButton")
	$"/root/AudioController".play_click()
	is_sound_on = !is_sound_on
	AudioServer.set_bus_mute(0, !is_sound_on)
	if is_sound_on:
		$CenterContainer/VBoxContainer/SoundButton.text = "Tắt âm thanh"
	else:
		$CenterContainer/VBoxContainer/SoundButton.text = "Bật âm thanh"

# Keep old functions for compatibility (won't be used)
func _on_continue_button_pressed():
	pass

func _on_replay_button_pressed():
	pass

func _on_home_button_pressed():
	pass

func _on_sound_button_pressed():
	pass

func _on_continue_pressed() -> void:
	pass


func _on_pause_pressed() -> void:
	pass # Replace with function body.
