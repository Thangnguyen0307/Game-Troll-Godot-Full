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
	var title = Label.new()
	title.text = "🎉 CHIẾN THẮNG! 🎉"
	title.add_theme_font_size_override("font_size", 72)
	title.add_theme_color_override("font_color", Color(1.0, 0.9, 0.2, 1.0))
	title.add_theme_color_override("font_outline_color", Color(0.2, 0.1, 0.5, 1.0))
	title.add_theme_constant_override("outline_size", 8)
	title.anchor_left = 0.5
	title.anchor_right = 0.5
	title.anchor_top = 0.2
	title.offset_left = -300
	title.offset_right = 300
	title.offset_top = -50
	title.offset_bottom = 50
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	control.add_child(title)
	
	# Subtitle
	var subtitle = Label.new()
	subtitle.text = "Bạn đã hoàn thành tất cả các màn chơi!"
	subtitle.add_theme_font_size_override("font_size", 32)
	subtitle.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
	subtitle.anchor_left = 0.5
	subtitle.anchor_right = 0.5
	subtitle.anchor_top = 0.3
	subtitle.offset_left = -400
	subtitle.offset_right = 400
	subtitle.offset_top = -20
	subtitle.offset_bottom = 20
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	control.add_child(subtitle)
	
	# Stats
	var stats = RichTextLabel.new()
	var death_count = GameManager.get_death_count() if GameManager else 0
	var max_level = GameManager.max_level_unlocked if GameManager else 20
	stats.bbcode_enabled = true
	stats.text = "[center][b]THỐNG KÊ:[/b]\n\n"
	stats.text += "Cấp độ hoàn thành: [color=green]" + str(max_level) + "[/color]\n"
	stats.text += "Tổng số lần chết: [color=red]" + str(death_count) + "[/color][/center]"
	stats.add_theme_font_size_override("normal_font_size", 28)
	stats.add_theme_font_size_override("bold_font_size", 32)
	stats.anchor_left = 0.5
	stats.anchor_right = 0.5
	stats.anchor_top = 0.45
	stats.offset_left = -250
	stats.offset_right = 250
	stats.offset_top = -60
	stats.offset_bottom = 60
	stats.fit_content = true
	stats.scroll_active = false
	control.add_child(stats)
	
	# VBoxContainer cho các buttons
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 20)
	vbox.anchor_left = 0.5
	vbox.anchor_right = 0.5
	vbox.anchor_top = 0.65
	vbox.offset_left = -150
	vbox.offset_right = 150
	vbox.offset_top = 0
	vbox.offset_bottom = 200
	control.add_child(vbox)
	
	# Credits button
	var credits_btn = Button.new()
	credits_btn.text = "📜 XEM CREDITS"
	credits_btn.custom_minimum_size = Vector2(300, 60)
	credits_btn.add_theme_font_size_override("font_size", 28)
	credits_btn.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	credits_btn.add_theme_color_override("font_hover_color", Color(1, 1, 0, 1))
	credits_btn.pressed.connect(_on_credits_pressed)
	vbox.add_child(credits_btn)
	
	# Main menu button
	var menu_btn = Button.new()
	menu_btn.text = "🏠 MENU CHÍNH"
	menu_btn.custom_minimum_size = Vector2(300, 60)
	menu_btn.add_theme_font_size_override("font_size", 28)
	menu_btn.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	menu_btn.add_theme_color_override("font_hover_color", Color(1, 1, 0, 1))
	menu_btn.pressed.connect(_on_menu_pressed)
	vbox.add_child(menu_btn)
	
	# Quit button
	var quit_btn = Button.new()
	quit_btn.text = "❌ THOÁT GAME"
	quit_btn.custom_minimum_size = Vector2(300, 60)
	quit_btn.add_theme_font_size_override("font_size", 28)
	quit_btn.add_theme_color_override("font_color", Color(1, 0.8, 0.8, 1))
	quit_btn.add_theme_color_override("font_hover_color", Color(1, 0, 0, 1))
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
		"res://main_menu.tscn"
	]
	
	for path in menu_paths:
		if ResourceLoader.exists(path):
			get_tree().change_scene_to_file(path)
			return
	
	print("Main menu not found!")

func _on_quit_pressed():
	print("Quitting game...")
	get_tree().quit()
