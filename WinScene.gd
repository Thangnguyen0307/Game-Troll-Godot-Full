extends Node2D

func _ready():
	# Tạo UI overlay cho win scene
	create_win_ui()

func create_win_ui():
	# Create CanvasLayer
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 10
	add_child(canvas_layer)
	
	# Create Control container
	var control = Control.new()
	control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	canvas_layer.add_child(control)
	
	# Victory title
	#var title = Label.new()
	#title.text = "🎉 CHIẾN THẮNG! 🎉"
	#title.add_theme_font_size_override("font_size", 80)
	#title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0, 1.0))  # Vàng đậm
	#title.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 1.0))  # Viền đen
	#title.add_theme_constant_override("outline_size", 12)  # Viền dày hơn
	#title.anchor_left = 0.5
	#title.anchor_right = 0.5
	#title.anchor_top = 0.15
	#title.offset_left = -350
	#title.offset_right = 350
	#title.offset_top = -50
	#title.offset_bottom = 50
	#title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	#control.add_child(title)
	#
	## Subtitle
	#var subtitle = Label.new()
	#subtitle.text = "Bạn đã hoàn thành tất cả các màn chơi!"
	#subtitle.add_theme_font_size_override("font_size", 36)
	#subtitle.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
	#subtitle.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.8))
	#subtitle.add_theme_constant_override("outline_size", 4)
	#subtitle.anchor_left = 0.5
	#subtitle.anchor_right = 0.5
	#subtitle.anchor_top = 0.28
	#subtitle.offset_left = -450
	#subtitle.offset_right = 450
	#subtitle.offset_top = -20
	#subtitle.offset_bottom = 20
	#subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	#control.add_child(subtitle)
	
	# Stats
	var stats = RichTextLabel.new()
	var death_count = GameManager.get_death_count() if GameManager else 0
	var max_level = GameManager.max_level_unlocked if GameManager else 20
	stats.bbcode_enabled = true
	stats.text = "[center][b][color=#FFD700][/color][/b]\n\n"
	stats.text += "[color=#FFFFFF]Cấp độ hoàn thành:[/color] [color=#00FF00][b]" + str(max_level) + "[/b][/color]\n"
	stats.text += "[color=#FFFFFF]Tổng số lần chết:[/color] [color=#FF5555][b]" + str(death_count) + "[/b][/color][/center]"
	stats.add_theme_font_size_override("normal_font_size", 30)
	stats.add_theme_font_size_override("bold_font_size", 36)
	stats.add_theme_color_override("default_color", Color(1.0, 1.0, 1.0, 1.0))
	stats.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.9))
	stats.add_theme_constant_override("outline_size", 3)
	stats.anchor_left = 0.5
	stats.anchor_right = 0.5
	stats.anchor_top = 0.38  # Cao hơn để tạo không gian cho buttons
	stats.offset_left = -280
	stats.offset_right = 280
	stats.offset_top = -65
	stats.offset_bottom = 65
	stats.fit_content = true
	stats.scroll_active = false
	control.add_child(stats)
	
	# VBoxContainer cho các buttons
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 25)  # Giảm khoảng cách để fit vào màn hình
	vbox.anchor_left = 0.5
	vbox.anchor_right = 0.5
	vbox.anchor_top = 0.58  # Cao hơn để hiển thị đủ 3 nút
	vbox.offset_left = -225
	vbox.offset_right = 225
	vbox.offset_top = 0
	vbox.offset_bottom = 340  # Tăng chiều cao
	control.add_child(vbox)
	
	# Credits button
	var credits_btn = Button.new()
	credits_btn.text = "📜 XEM CREDITS"
	credits_btn.custom_minimum_size = Vector2(450, 80)
	credits_btn.add_theme_font_size_override("font_size", 36)
	credits_btn.add_theme_color_override("font_color", Color(1.0, 0.95, 0.7, 1.0))  # Vàng nhạt
	credits_btn.add_theme_color_override("font_hover_color", Color(1.0, 0.85, 0.0, 1.0))  # Vàng đậm
	credits_btn.add_theme_color_override("font_pressed_color", Color(0.9, 0.75, 0.0, 1.0))
	credits_btn.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 1.0))
	credits_btn.add_theme_constant_override("outline_size", 3)
	# QUAN TRỌNG: Bật mouse filter để mobile touch hoạt động
	credits_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	credits_btn.focus_mode = Control.FOCUS_ALL
	credits_btn.pressed.connect(_on_credits_pressed)
	vbox.add_child(credits_btn)
	
	# Main menu button
	var menu_btn = Button.new()
	menu_btn.text = "🏠 MENU CHÍNH"
	menu_btn.custom_minimum_size = Vector2(450, 80)
	menu_btn.add_theme_font_size_override("font_size", 36)
	menu_btn.add_theme_color_override("font_color", Color(0.7, 0.95, 1.0, 1.0))  # Xanh nhạt
	menu_btn.add_theme_color_override("font_hover_color", Color(0.3, 0.85, 1.0, 1.0))  # Xanh đậm
	menu_btn.add_theme_color_override("font_pressed_color", Color(0.2, 0.75, 0.9, 1.0))
	menu_btn.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 1.0))
	menu_btn.add_theme_constant_override("outline_size", 3)
	# QUAN TRỌNG: Bật mouse filter để mobile touch hoạt động
	menu_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	menu_btn.focus_mode = Control.FOCUS_ALL
	menu_btn.pressed.connect(_on_menu_pressed)
	vbox.add_child(menu_btn)
	
	# Quit button
	var quit_btn = Button.new()
	quit_btn.text = "❌ THOÁT GAME"
	quit_btn.custom_minimum_size = Vector2(450, 80)
	quit_btn.add_theme_font_size_override("font_size", 36)
	quit_btn.add_theme_color_override("font_color", Color(1.0, 0.7, 0.7, 1.0))  # Đỏ nhạt
	quit_btn.add_theme_color_override("font_hover_color", Color(1.0, 0.3, 0.3, 1.0))  # Đỏ đậm
	quit_btn.add_theme_color_override("font_pressed_color", Color(0.9, 0.2, 0.2, 1.0))
	quit_btn.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 1.0))
	quit_btn.add_theme_constant_override("outline_size", 3)
	# QUAN TRỌNG: Bật mouse filter để mobile touch hoạt động
	quit_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	quit_btn.focus_mode = Control.FOCUS_ALL
	quit_btn.pressed.connect(_on_quit_pressed)
	vbox.add_child(quit_btn)

func _on_credits_pressed():
	print("Going to Credits...")
	get_tree().change_scene_to_file("res://UI/Credits.tscn")

func _on_menu_pressed():
	print("Going to Main Menu...")
	var menu_paths = [
		"res://UI/main_menu.tscn",
		"res://Scenes/main_menu.tscn",
		"res://MainMenu.tscn",
		"res://main_menu.tscn",
		"res://All_Level/Scene Main Start/main.tscn"
	]
	
	for path in menu_paths:
		if ResourceLoader.exists(path):
			get_tree().change_scene_to_file(path)
			return
	
	print("Main menu not found!")

func _on_quit_pressed():
	print("Quitting game...")
	get_tree().quit()
