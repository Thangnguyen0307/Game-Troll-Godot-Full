extends Control

# Script đơn giản để hiển thị "LEVEL X" ở trên màn hình
@onready var level_label = Label.new()

func _ready():
	# Setup label
	level_label.text = "LEVEL " + str(GameManager.current_level)
	level_label.add_theme_font_size_override("font_size", 48)
	level_label.add_theme_color_override("font_color", Color.WHITE)
	level_label.add_theme_color_override("font_outline_color", Color.BLACK)
	level_label.add_theme_constant_override("outline_size", 3)
	
	# Position at top center
	level_label.anchor_left = 0.5
	level_label.anchor_right = 0.5
	level_label.anchor_top = 0.0
	level_label.anchor_bottom = 0.0
	level_label.offset_left = -100
	level_label.offset_right = 100
	level_label.offset_top = 30
	level_label.offset_bottom = 80
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	# Add to scene
	add_child(level_label)
	
	# Hide after 3 seconds
	await get_tree().create_timer(3.0).timeout
	queue_free()
	queue_free()
