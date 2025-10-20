extends Area2D

@export var saw_path: NodePath
@export var player_group: String = "player"
@export var move_up_distance: float = 100.0     # Saw trồi lên bao nhiêu pixel
@export var move_speed: float = 0.5            # Thời gian tween trồi lên
@export var visible_time: float = 2.0          # Dừng lại bao lâu trước khi biến mất
@export var fade_time: float = 0.8             # Thời gian fade-out khi quay lại

@onready var saw: Area2D = get_node_or_null(saw_path)

var player = null
var triggered: bool = false
var original_pos: Vector2
var current_tween: Tween
var prev_alive_state: bool = true

func _ready():
	if not saw:
		push_error("❌ Không tìm thấy node Saw. Kiểm tra lại saw_path.")
		return

	# Lưu vị trí ban đầu
	original_pos = saw.global_position

	# Ẩn Saw ban đầu
	_reset_saw_state()

	# Kết nối trigger
	connect("body_entered", Callable(self, "_on_body_entered"))

	# Lấy player và gắn signal chết
	player = get_tree().get_first_node_in_group(player_group)
	if player:
		if player.has_signal("player_died"):
			player.player_died.connect(_on_player_died)
		elif player.has_method("is_alive"):
			prev_alive_state = player.is_alive

func _process(delta):
	# fallback nếu player không có signal
	if player and not player.has_signal("player_died"):
		if prev_alive_state and player.is_alive == false:
			_on_player_died()
		prev_alive_state = player.is_alive

func _on_body_entered(body):
	if triggered or not body.is_in_group(player_group):
		return
	triggered = true
	_show_and_move_saw()

func _show_and_move_saw():
	if not saw:
		return

	saw.visible = true
	saw.monitoring = true
	var sprite := saw.get_node_or_null("AnimatedSprite2D")
	if not sprite:
		return

	sprite.modulate.a = 0.0  # bắt đầu trong suốt
	if current_tween:
		current_tween.kill()

	current_tween = create_tween()

	# Fade in + trồi lên cùng lúc
	var up_pos = original_pos + Vector2(0, -move_up_distance)
	current_tween.tween_property(sprite, "modulate:a", 1.0, 0.4)
	current_tween.parallel().tween_property(saw, "global_position", up_pos, move_speed).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	await current_tween.finished

	# Dừng lại 2 giây
	await get_tree().create_timer(visible_time).timeout

	# Fade out + quay về chỗ cũ
	_fade_out_and_return(sprite)

func _fade_out_and_return(sprite: AnimatedSprite2D):
	if not saw:
		return
	if current_tween:
		current_tween.kill()

	current_tween = create_tween()

	current_tween.tween_property(sprite, "modulate:a", 0.0, fade_time)
	current_tween.parallel().tween_property(saw, "global_position", original_pos, fade_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	await current_tween.finished

	_reset_saw_state()

func _reset_saw_state():
	if not saw:
		return
	if current_tween:
		current_tween.kill()
	current_tween = null
	saw.global_position = original_pos
	saw.visible = false
	saw.monitoring = false
	var sprite := saw.get_node_or_null("AnimatedSprite2D")
	if sprite:
		sprite.modulate.a = 0.0

func _on_player_died():
	# Khi player chết → reset và cho phép trigger lại
	_reset_saw_state()
	triggered = false
