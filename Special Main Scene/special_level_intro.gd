extends Control

@onready var label = $StoryLabel
@export var typewriter_speed: float = 0.05  # Tốc độ chữ chạy (giây/ký tự)
@export var line_pause_duration: float = 1.5  # Thời gian dừng giữa các dòng

var is_typing: bool = false
var skip_requested: bool = false

func _ready():
	# Không cần setup label nữa vì đã được cấu hình trong scene
	var current_lv = GameManager.current_level
	
	# Lấy text từ GameManager
	if GameManager.special_level_stories.has(current_lv):
		play_story(GameManager.special_level_stories[current_lv])
	else:
		_skip_intro()

func play_story(lines: Array):
	for line in lines:
		if skip_requested:
			break
		
		# Typewriter effect - chữ chạy từng chữ
		await show_text_typewriter(line)
		
		# Nếu click trong lúc đánh chữ, dòng hiện tại đã hiện full, reset để chuyển sang dòng tiếp
		var was_skip_current_line = skip_requested and is_typing == false
		if was_skip_current_line:
			skip_requested = false  # Reset để dòng tiếp chạy bình thường
		
		# Dừng một chút trước khi chuyển dòng tiếp
		if not skip_requested:
			await get_tree().create_timer(line_pause_duration).timeout
		
		# Fade out dòng hiện tại
		if not skip_requested:
			var tween = create_tween()
			tween.tween_property(label, "modulate:a", 0.0, 0.5)
			await tween.finished
	
	_skip_intro()

func show_text_typewriter(full_text: String):
	"""Hiển thị text từng chữ một (typewriter effect)"""
	is_typing = true
	label.text = ""
	label.modulate.a = 1.0
	
	for i in range(full_text.length()):
		if skip_requested:
			label.text = full_text  # Hiện hết luôn
			break
		
		label.text += full_text[i]
		await get_tree().create_timer(typewriter_speed).timeout
	
	is_typing = false

func _input(event):
	# Bấm để skip
	if event is InputEventMouseButton and event.pressed:
		if is_typing:
			# Nếu đang đánh chữ, hiện hết dòng hiện tại (chỉ skip dòng này)
			skip_requested = true
		else:
			# Nếu đã đánh xong, bấm lần 2 mới skip toàn bộ
			_skip_intro()

func _skip_intro():
	if skip_requested:
		return  # Tránh gọi 2 lần
	
	skip_requested = true
	# Vào màn chơi thật
	GameManager.go_to_actual_special_level(GameManager.current_level)
