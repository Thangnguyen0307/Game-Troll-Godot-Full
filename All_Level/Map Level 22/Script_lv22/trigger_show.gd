extends Area2D

@export var gai_node: Node2D
@export var trigger2_node: Node2D

@export var rise_distance: float = -15.0
@export var rush_distance: float = 352.0
@export var step_distance: float = 22.0
@export var step_delay: float = 0.08
@export var rise_duration: float = 0.3
@export var drop_distance: float = 40.0
@export var drop_duration: float = 0.3
@export var return_duration: float = 0.1
@export var player_group: String = "player"
@export var delay_before_trigger2: float = 0.3   # thời gian chờ trước khi trigger2 trồi

var _triggered = false
var _original_pos: Vector2
var _player = null
var _prev_alive_state := true

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

	if gai_node:
		_original_pos = gai_node.position

	_player = get_tree().get_first_node_in_group(player_group)
	if _player:
		# kết nối nếu player phát signal player_died (nếu có)
		if _player.has_signal("player_died"):
			_player.player_died.connect(_on_player_died)
		# nếu không có signal thì vẫn lưu trạng thái ban đầu nếu có thuộc tính is_alive
		elif "is_alive" in _player:
			_prev_alive_state = _player.is_alive

func _process(_delta):
	# fallback: nếu player không phát signal, giám sát biến is_alive để reset
	if _player and not _player.has_signal("player_died"):
		# nếu trước đó alive nhưng bây giờ false => player chết
		if _prev_alive_state and _player_is_alive() == false:
			_on_player_died()
		_prev_alive_state = _player_is_alive()

func _on_body_entered(body):
	if _triggered or not body.is_in_group(player_group):
		return
	_triggered = true
	_activate_spikes()

func _activate_spikes():
	if not gai_node:
		return
	print_debug("Trigger1: Gai trồi lên")

	var tween = create_tween()
	tween.tween_property(gai_node, "position", _original_pos + Vector2(0, rise_distance), rise_duration)
	tween.tween_callback(Callable(self, "_rush_step_by_step").bind(gai_node))

func _rush_step_by_step(gai_node: Node2D):
	var total_steps = int(rush_distance / step_distance)
	var step_vector = Vector2(step_distance, 0)

	for i in range(total_steps):
		await get_tree().create_timer(step_delay).timeout
		gai_node.position += step_vector

	_drop_down(gai_node)

func _drop_down(gai_node: Node2D):
	print_debug("Trigger1: Gai hạ xuống")
	var tween = create_tween()
	tween.tween_property(gai_node, "position", gai_node.position + Vector2(0, drop_distance), drop_duration)
	tween.tween_callback(Callable(self, "_return_to_original").bind(gai_node))

func _return_to_original(gai_node: Node2D):
	print_debug("Trigger1: Gai trở về vị trí ban đầu")
	var tween = create_tween()
	tween.tween_property(gai_node, "position", _original_pos, return_duration)
	tween.tween_callback(Callable(self, "_activate_trigger2_if_player_alive"))

# helper: robust kiểm tra player còn sống hay không
func _player_is_alive() -> bool:
	if not _player:
		return false
	# nếu player có method is_alive() (hàm), gọi nó
	if _player.has_method("is_alive"):
		# may be a method returning bool
		var ok := true
		var alive_val = false
		# try/catch mô phỏng: gọi an toàn
		alive_val = _player.is_alive()
		return bool(alive_val)
	# nếu player có thuộc tính is_alive (bool), đọc trực tiếp
	# sử dụng try-get để tránh lỗi nếu không tồn tại
	if _player.has_meta("is_alive"):
		return bool(_player.get_meta("is_alive"))
	# fallback: nếu trường is_alive tồn tại như thuộc tính, truy cập thẳng (thường đúng với script của bạn)
	# (GDScript cho phép truy cập trực tiếp; nếu không tồn tại sẽ ném lỗi — nhưng script player của bạn có is_alive var)
	if typeof(_player.is_alive) == TYPE_BOOL:
		return _player.is_alive
	# mặc định: coi là sống (an toàn hơn tùy trường hợp)
	return true

func _activate_trigger2_if_player_alive():
	if not trigger2_node:
		print_debug("❌ Trigger2 chưa được gán trong Inspector")
		return

	# kiểm tra ngay lúc này
	if not _player_is_alive():
		print_debug("❌ Player chết ngay sau Trigger1, không kích hoạt Trigger2")
		return

	# chờ thời gian định sẵn, nhưng kiểm tra lại sau khi chờ (player có thể chết trong lúc đợi)
	print_debug("✅ Trigger1 hoàn thành, chờ %s giây rồi cho Trigger2 trồi lên" % delay_before_trigger2)
	await get_tree().create_timer(delay_before_trigger2).timeout

	if not _player_is_alive():
		print_debug("❌ Player chết trong lúc chờ, không kích hoạt Trigger2")
		return

	# gọi hàm trên trigger2 (tên hàm tùy trigger2 script của bạn; mình dùng rise_from_ground)
	if trigger2_node.has_method("rise_from_ground"):
		trigger2_node.rise_from_ground()
		print_debug("▶ Trigger2 được kích hoạt (rise_from_ground)")
	elif trigger2_node.has_method("trigger2_rise_after_delay"):
		trigger2_node.trigger2_rise_after_delay()
		print_debug("▶ Trigger2 được kích hoạt (trigger2_rise_after_delay)")
	else:
		print_debug("❌ Trigger2 không có hàm trồi xác định (rise_from_ground / trigger2_rise_after_delay)")

func _on_player_died():
	reset_trigger()

func reset_trigger():
	_triggered = false
	if gai_node:
		gai_node.position = _original_pos
