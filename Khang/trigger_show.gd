extends Area2D

@export var gai_node: Node2D
@export var rise_distance: float = -15.0      # Trồi lên bao nhiêu pixel
@export var rush_distance: float = 352.0      # Tổng khoảng cách dịch chuyển ngang
@export var step_distance: float = 22.0       # Mỗi lần nhích bao nhiêu pixel
@export var step_delay: float = 0.08          # Thời gian giữa mỗi nhích
@export var rise_duration: float = 0.3        # Thời gian trồi lên
@export var drop_distance: float = 40.0       # Thụt xuống bao nhiêu pixel
@export var drop_duration: float = 0.3        # Thời gian thụt xuống
@export var return_duration: float = 0.1      #  Thời gian quay lại vị trí ban đầu
@export var player_group: String = "player"   # Nhóm player

var _triggered = false
var _original_pos: Vector2
var _player = null
var _prev_alive_state := true

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

	if gai_node:
		_original_pos = gai_node.position

	# 🔍 Theo dõi player để reset trigger khi chết
	_player = get_tree().get_first_node_in_group(player_group)
	if _player:
		if _player.has_signal("player_died"):
			_player.player_died.connect(_on_player_died)
		elif _player.has_method("is_alive"):
			_prev_alive_state = _player.is_alive

func _process(_delta):
	# Nếu player không có signal chết thì kiểm tra thủ công
	if _player and not _player.has_signal("player_died"):
		if _prev_alive_state and _player.is_alive == false:
			_on_player_died()
		_prev_alive_state = _player.is_alive

func _on_body_entered(body):
	if _triggered or not body.is_in_group(player_group):
		return
	_triggered = true
	_activate_spikes()

func _activate_spikes():
	if not gai_node:
		return

	var tween = create_tween()
	# 1️⃣ Trồi lên
	tween.tween_property(gai_node, "position", _original_pos + Vector2(0, rise_distance), rise_duration)
	# 2️⃣ Sau khi trồi lên → bắt đầu nhích tới
	tween.tween_callback(Callable(self, "_rush_step_by_step").bind(gai_node))

func _rush_step_by_step(gai_node: Node2D):
	var total_steps = int(rush_distance / step_distance)
	var step_vector = Vector2(step_distance, 0)

	# Di chuyển từng chút một (nhích)
	for i in range(total_steps):
		await get_tree().create_timer(step_delay).timeout
		gai_node.position += step_vector

	# Sau khi hoàn tất → thụt xuống
	_drop_down(gai_node)

func _drop_down(gai_node: Node2D):
	var tween = create_tween()
	tween.tween_property(
		gai_node,
		"position",
		gai_node.position + Vector2(0, drop_distance),
		drop_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(Callable(self, "_return_to_original").bind(gai_node))

func _return_to_original(gai_node: Node2D):
	var tween = create_tween()
	tween.tween_property(
		gai_node,
		"position",
		_original_pos,
		return_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

# 🔄 Reset khi player chết
func _on_player_died():
	reset_trigger()

func reset_trigger():
	_triggered = false
	if gai_node:
		gai_node.position = _original_pos
