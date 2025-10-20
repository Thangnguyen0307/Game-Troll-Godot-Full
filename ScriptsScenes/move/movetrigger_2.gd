extends Area2D

@export var gai1_path: NodePath
@export var gai2_path: NodePath
@export var move_distance_gai1: float = 100.0
@export var move_distance_gai2: float = 200.0
@export var move_duration: float = 0.8
@export var player_group: String = "player"

@onready var gai1: Area2D = get_node(gai1_path)
@onready var gai2: Area2D = get_node(gai2_path)

var _triggered := false
var original_pos_gai1: Vector2
var original_pos_gai2: Vector2
var current_tween1: Tween
var current_tween2: Tween
var player = null
var prev_alive_state: bool = true

func _ready():
	# Lưu vị trí ban đầu
	original_pos_gai1 = gai1.global_position
	original_pos_gai2 = gai2.global_position

	# Gai2 ẩn
	gai2.visible = false
	gai2.monitoring = false

	# Kết nối trigger
	connect("body_entered", Callable(self, "_on_body_entered"))

	# Lấy player
	player = get_tree().get_first_node_in_group(player_group)
	if player:
		if player.has_signal("player_died"):
			player.player_died.connect(_on_player_died)
		elif player.has_method("is_alive"):
			prev_alive_state = player.is_alive

func _process(delta):
	if player and not player.has_signal("player_died"):
		if prev_alive_state and player.is_alive == false:
			_on_player_died()
		prev_alive_state = player.is_alive

func _on_body_entered(body):
	if _triggered:
		return
	if body.is_in_group(player_group):
		_triggered = true
		_show_and_move_spikes()

func _show_and_move_spikes():
	# Hiện gai2
	gai2.visible = true
	gai2.monitoring = true

	# Hủy tween cũ nếu có
	if current_tween1:
		current_tween1.kill()
	if current_tween2:
		current_tween2.kill()

	# Tạo tween mới
	current_tween1 = create_tween()
	current_tween2 = create_tween()

	# Tính target dựa trên vị trí hiện tại (chứ không dựa vào original_pos)
	var target_pos_gai1 = gai1.global_position + Vector2(-move_distance_gai1, 0)
	var target_pos_gai2 = gai2.global_position + Vector2(-move_distance_gai2, 0)

	current_tween1.tween_property(gai1, "global_position", target_pos_gai1, move_duration)
	current_tween1.set_trans(Tween.TRANS_SINE)
	current_tween1.set_ease(Tween.EASE_OUT)

	current_tween2.tween_property(gai2, "global_position", target_pos_gai2, move_duration)
	current_tween2.set_trans(Tween.TRANS_SINE)
	current_tween2.set_ease(Tween.EASE_OUT)

func _on_player_died():
	reset_spikes()

func reset_spikes():
	# Hủy tween nếu đang chạy
	if current_tween1:
		current_tween1.kill()
		current_tween1 = null
	if current_tween2:
		current_tween2.kill()
		current_tween2 = null

	# Reset lại trạng thái ban đầu
	_triggered = false
	gai1.global_position = original_pos_gai1
	gai2.global_position = original_pos_gai2
	gai2.visible = false
	gai2.monitoring = false
