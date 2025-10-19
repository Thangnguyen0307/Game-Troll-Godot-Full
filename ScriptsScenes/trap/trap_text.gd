extends Area2D

@export var move_down_distance: float = 280.0   # Khoảng cách di chuyển xuống
@export var move_speed: float = 0.3             # Tốc độ di chuyển
@export var appear_delay: float = 0.5           # Delay khi xuất hiện

var start_position: Vector2
var target_position: Vector2
var current_tween: Tween
var is_visible_state: bool = false
var has_moved: bool = false

# States
enum TrapState {
	HIDDEN,
	APPEARED,
	MOVING
}
var current_state: TrapState = TrapState.HIDDEN

var player
var prev_alive_state: bool = true   # để bắt sự kiện player vừa chết → reset

func _ready():
	start_position = global_position
	target_position = start_position + Vector2(0, move_down_distance)
	
	# Kết nối signals trigger
	$TriggerArea1.body_entered.connect(_on_trigger_1_entered)
	$TriggerArea2.body_entered.connect(_on_trigger_2_entered)
	body_entered.connect(_on_deadly_area_entered)
	
	# Ẩn trap ban đầu
	visible = false
	set_collision_layer_value(1, false)
	
	add_to_group("resettable_traps")

	# tìm player
	player = get_tree().get_first_node_in_group("player")
	if player:
		prev_alive_state = player.is_alive

	print("Two-trigger trap ready at: ", global_position)

func _process(delta):
	if not player:
		return

	# Nếu player vừa chết → reset trap
	if prev_alive_state and not player.is_alive:
		_on_player_died()
	
	prev_alive_state = player.is_alive

func _on_trigger_1_entered(body):
	if body.is_in_group("player") and current_state == TrapState.HIDDEN:
		appear_trap()

func _on_trigger_2_entered(body):
	if body.is_in_group("player") and current_state == TrapState.APPEARED:
		move_trap_down()

func _on_deadly_area_entered(body):
	if body.is_in_group("player") and current_state != TrapState.HIDDEN:
		if body.has_method("die"):
			body.die()

func appear_trap():
	current_state = TrapState.APPEARED
	visible = true
	set_collision_layer_value(1, true)
	
	modulate = Color(1, 1, 1, 0)
	scale = Vector2(0.1, 0.1)
	
	if current_tween:
		current_tween.kill()
	current_tween = create_tween().set_parallel(true)
	current_tween.tween_property(self, "modulate", Color(1, 1, 1, 1), appear_delay)
	current_tween.tween_property(self, "scale", Vector2(1, 1), appear_delay)
	current_tween.tween_callback(func(): current_tween = null)

func move_trap_down():
	if has_moved:
		return
	current_state = TrapState.MOVING
	has_moved = true
	
	if current_tween:
		current_tween.kill()
	current_tween = create_tween()
	current_tween.tween_property(self, "global_position", target_position, move_speed)
	current_tween.tween_callback(func(): current_tween = null)

func _on_player_died():
	reset_object()

func reset_object():
	if current_tween:
		current_tween.kill()
		current_tween = null
	
	current_state = TrapState.HIDDEN
	has_moved = false
	global_position = start_position
	visible = false
	set_collision_layer_value(1, false)
	modulate = Color(1, 1, 1, 1)
	scale = Vector2(1, 1)
