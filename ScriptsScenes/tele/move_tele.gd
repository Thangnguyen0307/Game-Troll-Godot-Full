extends Area2D

@export var teleport_node: NodePath
@export var move_distance: float = 240.0        # khoảng cách dịch sang phải
@export var right_speed: float = 0.3            # thời gian chạy sang phải
@export var left_distance: float = -200.0       # khoảng cách dịch sang trái (so với start_pos)
@export var left_speed_factor: float = 3.0      # tốc độ chạy sang trái nhanh hơn
@export var wait_time: float = 0.3             # thời gian dừng lại trước khi sang trái

var player
var has_triggered = false

var teleport: Node2D
var teleport_start_pos: Vector2
var current_tween = null   # tham chiếu tới SceneTreeTween đang chạy

func _ready():
	teleport = get_node_or_null(teleport_node)
	if teleport:
		teleport_start_pos = teleport.global_position

	player = get_tree().get_first_node_in_group("player")

func _on_body_entered(body):
	if not body.is_in_group("player"):
		return
	if not teleport:
		return

	# Dừng tween cũ nếu còn chạy
	if current_tween:
		current_tween.kill()
		current_tween = null

	# Tạo tween mới
	current_tween = get_tree().create_tween()
	current_tween.connect("finished", Callable(self, "_on_tween_finished"))

	# 1. Sang phải
	var target_right = teleport.global_position + Vector2(move_distance, 0)
	current_tween.tween_property(teleport, "global_position", target_right, right_speed)

	# 2. Dừng lại
	current_tween.tween_interval(wait_time)

	# 3. Sang trái (xa hơn vị trí ban đầu)
	var target_left = teleport_start_pos + Vector2(left_distance, 0)
	current_tween.tween_property(
		teleport,
		"global_position",
		target_left,
		right_speed / left_speed_factor
	)

	has_triggered = true
	monitoring = false

func _on_tween_finished():
	current_tween = null

func _process(delta):
	if has_triggered and player and not player.is_alive:
		reset_state()

func reset_state():
	if current_tween:
		current_tween.kill()
		current_tween = null

	if teleport:
		teleport.global_position = teleport_start_pos

	monitoring = true
	has_triggered = false
