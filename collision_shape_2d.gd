extends Node2D

@onready var spike_sprite: Sprite2D = $Sprite2D
@onready var spike_collision: CollisionShape2D = $CollisionShape2D
@onready var trigger_area: Area2D = $Trigger

var is_triggered: bool = false
var hidden_pos: Vector2
var shown_pos: Vector2

func _ready():
	# Ghi nhớ vị trí thật của gai (ở trên mặt đất)
	shown_pos = global_position
	# Vị trí ẩn dưới đất (ví dụ: thấp hơn 40px)
	hidden_pos = shown_pos + Vector2(0, 40)

	# Cho gai nằm ở dưới đất khi bắt đầu
	global_position = hidden_pos
	spike_collision.disabled = true

	# Kết nối trigger
	trigger_area.body_entered.connect(_on_trigger_area_entered)


func _on_trigger_area_entered(body: Node2D):
	if body.is_in_group("player") and not is_triggered:
		print("Player triggered spike trap!")
		is_triggered = true
		raise_spike()


func raise_spike():
	var tween = create_tween()
	# Tween di chuyển từ hidden lên shown
	tween.tween_property(self, "global_position", shown_pos, 0.3)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)

	# Khi tween xong → bật va chạm để Player chết
	tween.finished.connect(func ():
		spike_collision.disabled = false
	)


func reset_trap():
	# Reset lại bẫy nếu cần
	global_position = hidden_pos
	is_triggered = false
	spike_collision.disabled = true
