extends CanvasLayer
@onready var left: TouchScreenButton = $Left
@onready var right: TouchScreenButton = $Right
@onready var jump: TouchScreenButton = $Jump

# Biến theo dõi touch events
var active_touches = {}  # Dictionary lưu vị trí của từng touch point
var current_direction_button = null  # Nút direction hiện đang active (left/right)
var jump_touch_index = -1  # Touch index đang giữ jump
var direction_touch_index = -1  # Touch index đang giữ direction

# Vùng chạm của từng button (sẽ được tính trong _ready)
var left_rect: Rect2
var right_rect: Rect2
var jump_rect: Rect2

func _ready():
	# Tính vùng chạm của từng button dựa trên texture size và position
	_calculate_button_rects()
	
	# Disable các TouchScreenButton's built-in input
	# để chúng không "ăn" touch events
	left.process_mode = Node.PROCESS_MODE_DISABLED
	right.process_mode = Node.PROCESS_MODE_DISABLED
	jump.process_mode = Node.PROCESS_MODE_DISABLED
	
	# Enable input processing
	set_process_input(true)
	print("🎮 Touch Controls ready - Swipe enabled!")
	print("  Left rect: ", left_rect)
	print("  Right rect: ", right_rect)
	print("  Jump rect: ", jump_rect)

func _calculate_button_rects():
	# Tính toán Rect2 cho mỗi button dựa trên position và texture size
	if left.texture_normal:
		var size = left.texture_normal.get_size() * left.scale
		left_rect = Rect2(left.position, size)
	
	if right.texture_normal:
		var size = right.texture_normal.get_size() * right.scale
		right_rect = Rect2(right.position, size)
	
	if jump.texture_normal:
		var size = jump.texture_normal.get_size() * jump.scale
		jump_rect = Rect2(jump.position, size)

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			# Bắt đầu touch
			active_touches[event.index] = event.position
			_handle_touch_down(event.position, event.index)
		else:
			# Kết thúc touch
			_handle_touch_up(event.index)
			active_touches.erase(event.index)
	
	elif event is InputEventScreenDrag:
		# Kéo/lướt ngón tay - KEY FEATURE: detect khi drag giữa các button
		active_touches[event.index] = event.position
		_handle_touch_drag(event.position, event.index)

func _handle_touch_down(pos: Vector2, touch_index: int):
	# Xử lý khi bắt đầu chạm
	if left_rect.has_point(pos) or right_rect.has_point(pos):
		direction_touch_index = touch_index
		_update_direction_input(pos)
	elif jump_rect.has_point(pos):
		jump_touch_index = touch_index
		_press_jump()

func _handle_touch_drag(pos: Vector2, touch_index: int):
	# Xử lý khi kéo ngón tay - QUAN TRỌNG NHẤT
	if touch_index == direction_touch_index:
		# Đang kéo trong vùng direction (left/right)
		_update_direction_input(pos)
	elif touch_index == jump_touch_index:
		# Kiểm tra xem còn trong vùng jump không
		if not jump_rect.has_point(pos):
			_release_jump()
			jump_touch_index = -1

func _handle_touch_up(touch_index: int):
	# Xử lý khi nhấc tay
	if touch_index == direction_touch_index:
		_release_direction()
		direction_touch_index = -1
	elif touch_index == jump_touch_index:
		_release_jump()
		jump_touch_index = -1

func _update_direction_input(pos: Vector2):
	# Cập nhật input direction dựa trên vị trí
	var in_left = left_rect.has_point(pos)
	var in_right = right_rect.has_point(pos)
	
	if in_left and current_direction_button != "left":
		# Chuyển sang trái
		_release_direction()
		current_direction_button = "left"
		left.modulate.a = 0.5
		Input.action_press("left")
		#print("👈 LEFT") #debug
		
	elif in_right and current_direction_button != "right":
		# Chuyển sang phải
		_release_direction()
		current_direction_button = "right"
		right.modulate.a = 0.5
		Input.action_press("right")
		#print("👉 RIGHT") #debug
		
	elif not in_left and not in_right:
		# Rời khỏi cả 2 button
		_release_direction()

func _release_direction():
	# Release direction input
	if current_direction_button == "left":
		left.modulate.a = 1.0
		Input.action_release("left")
	elif current_direction_button == "right":
		right.modulate.a = 1.0
		Input.action_release("right")
	current_direction_button = null

func _press_jump():
	jump.modulate.a = 0.5
	Input.action_press("jump")
	

func _release_jump():
	jump.modulate.a = 1.0
	Input.action_release("jump")

# Fallback callbacks
func _on_left_pressed() -> void:
	pass

func _on_left_released() -> void:
	pass

func _on_right_pressed() -> void:
	pass

func _on_right_released() -> void:
	pass

func _on_jump_pressed() -> void:
	pass

func _on_jump_released() -> void:
	pass
