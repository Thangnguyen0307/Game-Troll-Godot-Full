extends Area2D

@export var saw_path: NodePath
@export var player_group: String = "player"

# ⚙️ Thông số phóng to
@export var target_scale: Vector2 = Vector2(1.5, 1.5)
@export var scale_duration: float = 0.4

# ⚙️ Di chuyển pha 1 – Sang trái
@export var move_left_distance: float = 2380.0
@export var move_left_duration: float = 6.0

# ⚙️ Dừng giữa các pha
@export var wait_after_left: float = 1.0
@export var wait_after_down: float = 1.0

# ⚙️ Di chuyển pha 2 – Đi xuống
@export var move_down_distance: float = 80.0
@export var move_down_duration: float = 1.2  # chậm hơn

# ⚙️ Di chuyển pha 3 – Sang phải
@export var move_right_distance: float = 200.0
@export var move_right_duration: float = 0.8

@onready var saw: Area2D = get_node_or_null(saw_path)

var original_scale: Vector2
var original_pos: Vector2
var triggered: bool = false
var current_tween: Tween
var player = null
var prev_alive_state: bool = true

func _ready():
	if not saw:
		push_error("⚠️ Không tìm thấy node Saw. Kiểm tra lại saw_path.")
		return

	# Lưu trạng thái ban đầu
	original_scale = saw.scale
	original_pos = saw.global_position

	# Kết nối trigger
	connect("body_entered", Callable(self, "_on_body_entered"))

	# Lấy player
	player = get_tree().get_first_node_in_group(player_group)
	if player:
		if player.has_signal("player_died"):
			player.player_died.connect(_on_player_died)
		elif player.has_method("is_alive"):
			prev_alive_state = player.is_alive

func _process(_delta):
	# Nếu player không có signal thì tự kiểm tra trạng thái sống
	if player and not player.has_signal("player_died"):
		if prev_alive_state and player.is_alive == false:
			_on_player_died()
		prev_alive_state = player.is_alive


func _on_body_entered(body):
	if not body.is_in_group(player_group):
		return
	if triggered:
		return
	
	triggered = true
	_enlarge_and_move_saw()


func _enlarge_and_move_saw():
	if not saw:
		return

	if current_tween:
		current_tween.kill()

	current_tween = create_tween()

	# 🟢 1️⃣ Tween phóng to
	current_tween.tween_property(saw, "scale", target_scale, scale_duration) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_OUT)

	# 🔵 2️⃣ Sau khi phóng to xong → di chuyển sang trái
	var pos_left = original_pos + Vector2(-move_left_distance, 0)
	current_tween.tween_property(saw, "global_position", pos_left, move_left_duration) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN_OUT)

	# ⏸ 3️⃣ Dừng 1 giây
	current_tween.tween_interval(wait_after_left)

	# 🟣 4️⃣ Di chuyển xuống
	var pos_down = pos_left + Vector2(0, move_down_distance)
	current_tween.tween_property(saw, "global_position", pos_down, move_down_duration) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_OUT)

	# ⏸ 5️⃣ Dừng 1 giây
	current_tween.tween_interval(wait_after_down)

	# 🟠 6️⃣ Di chuyển sang phải
	var pos_right = pos_down + Vector2(move_right_distance, 0)
	current_tween.tween_property(saw, "global_position", pos_right, move_right_duration) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN_OUT)

	current_tween.tween_callback(func():
		current_tween = null
	)


func _on_player_died():
	reset_saw()


func reset_saw():
	if not saw:
		return

	if current_tween:
		current_tween.kill()
		current_tween = null

	triggered = false
	saw.scale = original_scale
	saw.global_position = original_pos
