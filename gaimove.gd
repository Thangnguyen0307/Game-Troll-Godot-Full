extends Area2D

@export var trap_node: NodePath        # trỏ tới Area2D bẫy (ví dụ gai)
@export var move_distance: float = 200.0
@export var move_speed: float = 0.4

var trap: Area2D
var start_pos: Vector2
var target_pos: Vector2
var has_triggered: bool = false
var current_tween: Tween
var player = null
var prev_alive_state: bool = true

func _ready():
	trap = get_node_or_null(trap_node)
	if trap:
		start_pos = trap.global_position
		target_pos = start_pos + Vector2(-move_distance, 0)

	player = get_tree().get_first_node_in_group("player")
	body_entered.connect(_on_body_entered)

	# Kết nối khi player chết
	if player:
		if player.has_signal("player_died"):
			player.player_died.connect(_on_player_died)
		elif player.has_method("is_alive"):
			prev_alive_state = player.is_alive

func _process(delta):
	# Nếu player không có signal chết thì tự kiểm tra
	if player and not player.has_signal("player_died"):
		if prev_alive_state and player.is_alive == false:
			_on_player_died()
		prev_alive_state = player.is_alive

func _on_body_entered(body):
	if not body or not body.is_in_group("player"):
		return
	if has_triggered:
		return  # chỉ 1 lần / 1 lượt sống của player

	move_trap()
	has_triggered = true

func move_trap():
	if not trap:
		return

	if current_tween:
		current_tween.kill()

	current_tween = create_tween()
	current_tween.tween_property(trap, "global_position", target_pos, move_speed)
	current_tween.tween_callback(func():
		current_tween = null
	)

func _on_player_died():
	reset_trap()

func reset_trap():
	if not trap:
		return
	if current_tween:
		current_tween.kill()
	current_tween = null

	# reset lại trap về chỗ ban đầu
	trap.global_position = start_pos

	# Cho trigger hoạt động lại
	has_triggered = false
