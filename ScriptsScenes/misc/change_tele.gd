extends Area2D

@export var teleport_node: NodePath             # teleport chính (cái gắn script này)
@export var other_teleport_node: NodePath       # teleport còn lại (để đổi chỗ)
@export var swap_time: float = 0.5              # thời gian hoán đổi
@export var wait_time: float = 0.2              # thời gian dừng trước khi swap

var player
var has_triggered = false

var teleport: Node2D
var other_teleport: Node2D
var teleport_start_pos: Vector2
var other_start_pos: Vector2
var current_tween = null

func _ready():
	teleport = get_node_or_null(teleport_node)
	other_teleport = get_node_or_null(other_teleport_node)

	if teleport:
		teleport_start_pos = teleport.global_position
	if other_teleport:
		other_start_pos = other_teleport.global_position

	player = get_tree().get_first_node_in_group("player")

func _on_body_entered(body):
	if not body.is_in_group("player"):
		return
	if not teleport or not other_teleport:
		return

	# Hủy tween cũ
	if current_tween:
		current_tween.kill()
		current_tween = null

	# Tạo tween swap
	current_tween = get_tree().create_tween()
	current_tween.connect("finished", Callable(self, "_on_tween_finished"))

	# dừng 1 chút
	current_tween.tween_interval(wait_time)

	# swap vị trí
	var pos_a = teleport.global_position
	var pos_b = other_teleport.global_position
	current_tween.parallel().tween_property(teleport, "global_position", pos_b, swap_time)
	current_tween.parallel().tween_property(other_teleport, "global_position", pos_a, swap_time)

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

	# đưa 2 teleport về vị trí ban đầu
	if teleport:
		teleport.global_position = teleport_start_pos
	if other_teleport:
		other_teleport.global_position = other_start_pos

	monitoring = true
	has_triggered = false
