extends Area2D

@export var saw_path: NodePath
@export var target_scale: Vector2 = Vector2(1.5, 1.5)  # Kích thước phóng to
@export var scale_duration: float = 0.4                 # Thời gian tween (mượt)
@export var player_group: String = "player"

@onready var saw: Area2D = get_node_or_null(saw_path)

var original_scale: Vector2
var triggered: bool = false
var current_tween: Tween
var player = null
var prev_alive_state: bool = true

func _ready():
	if not saw:
		push_error("⚠️ Không tìm thấy node Saw. Kiểm tra lại saw_path.")
		return

	# Lưu kích thước ban đầu
	original_scale = saw.scale

	# Kết nối trigger
	connect("body_entered", Callable(self, "_on_body_entered"))

	# Tìm player trong scene
	player = get_tree().get_first_node_in_group(player_group)
	if player:
		if player.has_signal("player_died"):
			player.player_died.connect(_on_player_died)
		elif player.has_method("is_alive"):
			prev_alive_state = player.is_alive

func _process(delta):
	# Nếu player không có signal thì tự kiểm tra trạng thái sống
	if player and not player.has_signal("player_died"):
		if prev_alive_state and player.is_alive == false:
			_on_player_died()
		prev_alive_state = player.is_alive

func _on_body_entered(body):
	if not body.is_in_group(player_group):
		return
	if triggered:
		return  # chỉ kích hoạt 1 lần mỗi lượt sống của player
	
	triggered = true
	_enlarge_saw()

func _enlarge_saw():
	if not saw:
		return

	if current_tween:
		current_tween.kill()

	current_tween = create_tween()
	current_tween.tween_property(saw, "scale", target_scale, scale_duration)
	current_tween.set_trans(Tween.TRANS_SINE)
	current_tween.set_ease(Tween.EASE_OUT)

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
