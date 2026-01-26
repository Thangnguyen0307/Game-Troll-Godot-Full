extends Control

@onready var label = $StoryLabel

func _ready():
	var current_lv = GameManager.current_level
	
	# Lấy text từ GameManager
	if GameManager.special_level_stories.has(current_lv):
		play_story(GameManager.special_level_stories[current_lv])
	else:
		_skip_intro()

func play_story(lines: Array):
	for line in lines:
		label.text = line
		label.modulate.a = 0 # Ẩn chữ
		
		var tween = create_tween()
		tween.tween_property(label, "modulate:a", 1.0, 1.0) # Hiện dần
		tween.tween_interval(2.0) # Đọc trong 2s
		tween.tween_property(label, "modulate:a", 0.0, 1.0) # Mờ dần
		
		await tween.finished
	
	_skip_intro()

func _input(event):
	# Bấm chuột để bỏ qua
	if event is InputEventMouseButton and event.pressed: _skip_intro()

func _skip_intro():
	# Vào màn chơi thật
	GameManager.go_to_actual_special_level(GameManager.current_level)
