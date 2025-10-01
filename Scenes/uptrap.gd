extends Node2D   # Script gắn vào node chính của cái bẫy (Trap)

@onready var spike_sprite: Sprite2D = $Sprite2D
@onready var spike_collision: CollisionShape2D = $CollisionShape2D
@onready var trigger_area: Area2D = $Trigger

var is_triggered: bool = false
var hidden_pos: Vector2
var shown_pos: Vector2

func _ready():
	# Lưu lại vị trí thật (trên mặt đất)
	shown_pos = global_position
	# Vị trí ẩn (dưới đất 40px)
	hidden_pos = shown_pos + Vector2(0, 40)

	# Đặt bẫy xuống đất khi bắt đầu
	global_position = hidden_pos

	# Tắt va chạm lúc đầu
	if spike_collision:
		spike_collision.set_deferred("disabled", true)

	# Kết nối trigger
	if trigger_area:
		trigger_area.body_entered.connect(_on_trigger_area_entered)
	else:
		push_error("Trigger node not found!")


# Khi player đi vào trigger
func _on_trigger_area_entered(body: Node2D):
	if body.is_in_group("player") and not is_triggered:
		print("Player triggered spike trap!")
		is_triggered = true
		raise_spike()


# Hàm phóng gai lên trên
func raise_spike():
	# Tween phóng lên nhanh trong 0.1 giây
	var tween = create_tween()
	tween.tween_property(self, "global_position", shown_pos, 0.1).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)

	# Bật va chạm khi gai đã lên
	tween.finished.connect(func ():
		if spike_collision:
			spike_collision.set_deferred("disabled", false)
	)


# Reset lại bẫy (ẩn xuống dưới, tắt va chạm, chờ kích hoạt lại)
func reset_trap():
	global_position = hidden_pos
	is_triggered = false
	if spike_collision:
		spike_collision.set_deferred("disabled", true)
