extends Area2D

@export_group("Movement")
@export var distances: Array[float] = [90.0, 90.0, 150.0, 150.0]  # [down, up, left, right]
@export var speeds: Array[float] = [0.5, 0.3, 0.8, 0.2]           # [down, up, left, right]
@export var delays: Array[float] = [0.0, 0.0, 0.0, 0.0]           # [before_down, before_up, before_left, before_right]
@export var reset_delay: float = 2.0                               # Delay reset khi player chết

@export_group("Activation")
@export var is_active: bool = false                                # Trap có active không (thay vì auto_trigger)

var start_pos: Vector2
var positions: Array[Vector2]
var triggered = false
var tween: Tween
var reset_timer: Timer

func _ready():
	start_pos = global_position
	_calculate_positions()
	body_entered.connect(_on_deadly_touch)
	
	# Luôn connect TriggerArea, nhưng chỉ hoạt động khi is_active = true
	if has_node("TriggerArea"):
		$TriggerArea.body_entered.connect(_on_trigger)
	
	add_to_group("resettable_traps")
	print("Trap ready - Active: ", is_active)

func _calculate_positions():
	positions = [start_pos]
	positions.append(start_pos + Vector2(0, distances[0]))           # down
	positions.append(positions[1] + Vector2(0, -distances[1]))       # up
	positions.append(positions[2] + Vector2(-distances[2], 0))       # left  
	positions.append(positions[3] + Vector2(distances[3], 0))        # right

func _on_deadly_touch(body):
	# Chỉ deadly khi trap active
	if body.is_in_group("player") and is_active:
		print("Player touched active deadly trap!")
		body.die()
		_delayed_reset()

func _on_trigger(body):
	# Chỉ trigger khi trap active và chưa triggered
	if body.is_in_group("player") and not triggered and is_active:
		print("Player triggered active trap movement!")
		triggered = true
		_move_sequence()

# ✅ THAY ĐỔI: activate_trap() chỉ bật chức năng, không kích hoạt di chuyển
func activate_trap():
	"""Được gọi từ ActivationZone - BẬT chức năng trap"""
	is_active = true
	print("Trap activated (enabled): ", name)

# ✅ THÊM: Method để tắt trap
func deactivate_trap():
	"""Tắt chức năng trap"""
	is_active = true
	print("Trap deactivated (disabled): ", name)

func _move_sequence():
	print("Starting trap movement sequence")
	if tween: tween.kill()
	tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	
	for i in range(4):
		# Delay TRƯỚC khi di chuyển
		if delays[i] > 0: 
			tween.tween_interval(delays[i])
		
		tween.tween_property(self, "global_position", positions[i + 1], speeds[i])
	
	tween.tween_callback(func(): tween = null)

func _delayed_reset():
	if reset_timer:
		reset_timer.queue_free()
	
	reset_timer = Timer.new()
	add_child(reset_timer)
	reset_timer.wait_time = reset_delay
	reset_timer.one_shot = true
	reset_timer.timeout.connect(_do_reset)
	reset_timer.start()

func _do_reset():
	if tween: tween.kill()
	global_position = start_pos
	triggered = false
	is_active = false  # Reset về inactive state
	
	if reset_timer:
		reset_timer.queue_free()
		reset_timer = null
	
	print("Trap reset - now inactive")

func reset_object():
	_delayed_reset()
