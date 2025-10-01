extends Node2D   # Script gắn vào node chính của cái bẫy (Trap)

# Lấy Sprite2D trong scene (hình cái gai)
@onready var spike_sprite: Sprite2D = $Sprite2D

# Lấy CollisionShape2D trong scene (phần va chạm của gai)
@onready var spike_collision: CollisionShape2D = $CollisionShape2D

# Lấy Area2D trong scene (vùng trigger để phát hiện Player)
@onready var trigger_area: Area2D = $Trigger

# Biến cờ để biết bẫy đã được kích hoạt hay chưa
var is_triggered: bool = false

# Vị trí ẩn dưới đất
var hidden_pos: Vector2
# Vị trí hiện trên mặt đất
var shown_pos: Vector2

func _ready():
	# Lưu lại vị trí thật của gai (trên mặt đất)
	shown_pos = global_position

	# Xác định vị trí ẩn (thấp hơn 40px)
	hidden_pos = shown_pos + Vector2(0, 40)

	# Đặt gai xuống dưới đất khi bắt đầu
	global_position = hidden_pos

	# Tắt va chạm lúc đầu (nếu node tồn tại)
	if spike_collision:
		spike_collision.set_deferred("disabled", true)
	else:
		push_error("Không tìm thấy node CollisionShape2D!")

	# Kết nối sự kiện khi có body đi vào vùng trigger
	if trigger_area:
		trigger_area.body_entered.connect(_on_trigger_area_entered)
	else:
		push_error("Không tìm thấy node Trigger!")


func _on_trigger_area_entered(body: Node2D):
	if body.is_in_group("player") and not is_triggered:
		print("Player triggered spike trap!")
		is_triggered = true
		raise_spike()


func raise_spike():
	var tween = create_tween()
	tween.tween_property(self, "global_position", shown_pos, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	tween.finished.connect(func ():
		if spike_collision:
			spike_collision.set_deferred("disabled", false)
	)


func reset_trap():
	global_position = hidden_pos
	is_triggered = false
	if spike_collision:
		spike_collision.set_deferred("disabled", true)
