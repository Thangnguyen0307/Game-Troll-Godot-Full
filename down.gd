extends Node2D

@onready var spike_sprite: Sprite2D = $Sprite2D
@onready var spike_collision: CollisionShape2D = $CollisionShape2D
@onready var trigger_area: Area2D = $Trigger

var is_triggered: bool = false
var hidden_position: Vector2
var shown_position: Vector2

func _ready():
	# Lưu vị trí ban đầu (ẩn dưới đất)
	hidden_position = global_position + Vector2(0, 50)   # ẩn sâu xuống 50px
	shown_position = global_position                      # vị trí thật
	global_position = hidden_position

	# Lúc đầu ẩn collision để không giết Player
	spike_collision.disabled = true

	# Kết nối trigger
	trigger_area.body_entered.connect(_on_trigger_area_entered)


func _on_trigger_area_entered(body):
	if body.is_in_group("player") and not is_triggered:
		print("Player triggered spike trap!")
		is_triggered = true
		show_spike()


func show_spike():
	var tween = create_tween()
	# Tween di chuyển từ hidden lên shown
	tween.tween_property(self, "global_position", shown_position, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await tween.finished

	# Bật va chạm sau khi hiện ra
	spike_collision.disabled = false


func reset_trap():
	# Cho phép reset lại bẫy
	global_position = hidden_position
	is_triggered = false
	spike_collision.disabled = true
