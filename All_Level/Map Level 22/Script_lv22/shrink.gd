extends Area2D

@export var player_group: String = "player"    # Tên group của player
@export var shrink_scale: float = 0.5          # Tỷ lệ thu nhỏ player
@export var shrink_speed: float = 0.4          # Tốc độ tween thu nhỏ
@export var restore_speed: float = 0.3         # Tốc độ tween khôi phục
@export var speed_multiplier: float = 0.6      # Giảm tốc độ di chuyển
@export var jump_multiplier: float = 0.7       # Giảm lực nhảy

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var player: Node = null
var triggered: bool = false
var prev_alive_state: bool = true
var current_tween: Tween
var original_scale: Vector2

func _ready():
	sprite.play("default")
	connect("body_entered", Callable(self, "_on_body_entered"))

	player = get_tree().get_first_node_in_group(player_group)
	if player:
		original_scale = player.scale

		# Kết nối tín hiệu chết
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
	if triggered:
		return
	if not body.is_in_group(player_group):
		return

	triggered = true
	player = body
	original_scale = player.scale

	# Gọi hiệu ứng thu nhỏ
	_shrink_player()
	_apply_slow_effect()
	_hide_trigger()

func _shrink_player():
	if not player:
		return

	if current_tween:
		current_tween.kill()

	current_tween = create_tween()
	current_tween.tween_property(player, "scale", original_scale * shrink_scale, shrink_speed)
	current_tween.set_trans(Tween.TRANS_SINE)
	current_tween.set_ease(Tween.EASE_OUT)

func _apply_slow_effect():
	if not player:
		return

	# Lưu lại tốc độ và nhảy ban đầu (nếu chưa có)
	if not player.has_meta("original_speed"):
		player.set_meta("original_speed", player.current_speed)
		player.set_meta("original_jump_velocity", player.current_jump_velocity)

	# Giảm tốc độ và lực nhảy
	player.current_speed *= speed_multiplier
	player.current_jump_velocity *= jump_multiplier

func _hide_trigger():
	visible = false
	monitoring = false
	if sprite:
		sprite.visible = false

func _on_player_died():
	_restore_player()
	_show_trigger()

func _restore_player():
	if not player:
		return

	# Khôi phục scale
	if current_tween:
		current_tween.kill()
	current_tween = create_tween()
	current_tween.tween_property(player, "scale", original_scale, restore_speed)
	current_tween.set_trans(Tween.TRANS_SINE)
	current_tween.set_ease(Tween.EASE_OUT)

	# Khôi phục tốc độ và nhảy
	if player.has_meta("original_speed"):
		player.current_speed = player.get_meta("original_speed")
	if player.has_meta("original_jump_velocity"):
		player.current_jump_velocity = player.get_meta("original_jump_velocity")

func _show_trigger():
	triggered = false
	visible = true
	monitoring = true
	if sprite:
		sprite.visible = true
