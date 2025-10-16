extends Area2D

@export var gai_parent_path: NodePath      # trỏ tới Node2D "Gai" chứa 8 node gai
@export var player_group: String = "player"
@export var move_distance: float = 1000.0   # khoảng di chuyển sang trái
@export var move_speed: float = 0.6        # tốc độ di chuyển
@export var delay_before_move: float = 1.5 # thời gian chờ trước khi di chuyển

@onready var gai_parent: Node2D = get_node_or_null(gai_parent_path)

var triggered: bool = false
var player = null
var prev_alive_state: bool = true
var start_positions: Array = []
var tweens: Array = []

func _ready():
	if not gai_parent:
		push_error("Không tìm thấy node Gai. Kiểm tra lại gai_parent_path.")
		return

	# Lưu vị trí ban đầu và ẩn tất cả gai
	start_positions.clear()
	for child in gai_parent.get_children():
		if child is Area2D:
			start_positions.append(child.global_position)
			child.visible = false
			child.monitoring = false

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
	if triggered or not body.is_in_group(player_group):
		return
	triggered = true
	_show_spikes()

func _show_spikes():
	if not gai_parent:
		return

	for child in gai_parent.get_children():
		if child is Area2D:
			child.visible = true
			child.monitoring = true

	# Sau 1.5s thì di chuyển
	await get_tree().create_timer(delay_before_move).timeout
	_move_spikes()

func _move_spikes():
	tweens.clear()
	for i in range(len(gai_parent.get_children())):
		var child = gai_parent.get_child(i)
		if child is Area2D:
			var tween = create_tween()
			tween.tween_property(
				child,
				"global_position",
				child.global_position + Vector2(-move_distance, 0),
				move_speed
			)
			tweens.append(tween)

func _on_player_died():
	reset_spikes()

func reset_spikes():
	if not gai_parent:
		return

	triggered = false

	# Hủy tween nếu đang chạy
	for tween in tweens:
		if tween:
			tween.kill()
	tweens.clear()

	# Đưa về trạng thái ban đầu
	for i in range(len(gai_parent.get_children())):
		var child = gai_parent.get_child(i)
		if child is Area2D:
			child.visible = false
			child.monitoring = false
			child.global_position = start_positions[i] if i < start_positions.size() else child.global_position
