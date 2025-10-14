extends Control

@export var scroll_speed: float = 100.0  # Tốc độ scroll (pixels/giây)
@export var auto_scroll: bool = true
@export var use_tween_animation: bool = true  # Dùng Tween thay vì scroll manual

@onready var scroll_container = $ScrollContainer
@onready var vbox_container = $ScrollContainer/VBoxContainer
@onready var skip_button = $SkipButton
@onready var stats_label = $ScrollContainer/VBoxContainer/Stats

var scroll_position: float = 0.0
var is_scrolling: bool = true
var scroll_tween: Tween

func _ready():
	print("Credits scene loaded!")
	
	# Cập nhật thống kê
	update_stats()
	
	# Kết nối nút Skip
	if skip_button:
		skip_button.pressed.connect(_on_skip_pressed)
	
	# Reset scroll về đầu
	if scroll_container:
		scroll_container.scroll_vertical = 0
		print("ScrollContainer found!")
	
	# Đợi 1 frame để UI setup xong
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Debug info
	if scroll_container:
		var v_scroll = scroll_container.get_v_scroll_bar()
		print("VScrollBar max_value: ", v_scroll.max_value)
		print("ScrollContainer size: ", scroll_container.size)
		if vbox_container:
			print("VBoxContainer size: ", vbox_container.size)
			print("VBoxContainer custom_minimum_size: ", vbox_container.custom_minimum_size)
	
	# Bắt đầu scroll bằng Tween
	if use_tween_animation and scroll_container:
		start_tween_scroll()

func start_tween_scroll():
	"""Scroll bằng Tween animation - mượt hơn"""
	var max_scroll = scroll_container.get_v_scroll_bar().max_value
	
	if max_scroll <= 0:
		print("⚠️ Cannot scroll - content not tall enough!")
		return
	
	var duration = max_scroll / scroll_speed
	print("Starting tween scroll - Duration: ", duration, "s, Max scroll: ", max_scroll)
	
	if scroll_tween:
		scroll_tween.kill()
	
	scroll_tween = create_tween()
	scroll_tween.tween_property(scroll_container, "scroll_vertical", max_scroll, duration)
	scroll_tween.tween_callback(func():
		print("Credits finished scrolling!")
		is_scrolling = false
		await get_tree().create_timer(3.0).timeout
		go_to_main_menu()
	)

func _process(delta: float) -> void:
	# Chỉ dùng manual scroll nếu không dùng Tween
	if use_tween_animation:
		return
	
	if not auto_scroll or not is_scrolling:
		return
	
	if scroll_container:
		# Tự động scroll xuống
		scroll_position += scroll_speed * delta
		scroll_container.scroll_vertical = int(scroll_position)
		
		# Kiểm tra đã scroll hết chưa
		var max_scroll = scroll_container.get_v_scroll_bar().max_value
		if scroll_container.scroll_vertical >= max_scroll - 10:
			is_scrolling = false
			print("Credits finished scrolling!")
			
			# Tự động quay về menu sau 3 giây
			await get_tree().create_timer(3.0).timeout
			go_to_main_menu()

func _input(event: InputEvent) -> void:
	# ESC để skip
	if event.is_action_pressed("ui_cancel"):
		_on_skip_pressed()
	
	# Scroll bằng tay
	if event.is_action_pressed("ui_down") or event.is_action_pressed("ui_up"):
		is_scrolling = false  # Tắt auto scroll khi người dùng scroll thủ công

func update_stats():
	"""Cập nhật thống kê từ GameManager"""
	if stats_label and GameManager:
		var death_count = GameManager.get_death_count()
		var max_level = GameManager.max_level_unlocked
		
		stats_label.text = "[center][b]THỐNG KÊ CỦA BẠN[/b]\n\n"
		stats_label.text += "Số lần chết: [color=red]" + str(death_count) + "[/color]\n"
		stats_label.text += "Cấp độ hoàn thành: [color=green]" + str(max_level) + "/20[/color][/center]"

func _on_skip_pressed():
	"""Skip credits và về menu"""
	print("Credits skipped!")
	go_to_main_menu()

func go_to_main_menu():
	"""Quay về Main Menu"""
	var menu_paths = [
		"res://UI/main_menu.tscn",
		"res://Scenes/main_menu.tscn",
		"res://MainMenu.tscn",
		"res://main_menu.tscn",
		"res://UI/level_select_menu.tscn"
	]
	
	for path in menu_paths:
		if ResourceLoader.exists(path):
			get_tree().change_scene_to_file(path)
			print("Going back to main menu: ", path)
			return
	
	print("Main menu not found! Staying on credits...")
