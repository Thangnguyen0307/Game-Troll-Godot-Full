extends AnimatableBody2D

@export_group("Movement")
@export var distances: Array[float] = [63.0, 100.0, 63.0]  # [up, left, down]
@export var speeds: Array[float] = [0.5, 0.8, 0.5]         # [up, left, down]
@export var delays: Array[float] = [0.0, 0.0, 0.0]         # [before_up, before_left, before_down]

@export_group("Activation")
@export var is_active: bool = false  # Platform có active không

var start_position: Vector2
var positions: Array[Vector2]
var triggered = false
var current_tween: Tween

@onready var trigger_area = $TriggerArea

func _ready():
	start_position = global_position
	_calculate_positions()
	
	# Luôn connect TriggerArea, nhưng chỉ hoạt động khi is_active = true
	if trigger_area:
		trigger_area.body_entered.connect(_on_trigger_entered)
	
	add_to_group("moving_platforms")
	print("Platform ready - Active: ", is_active)

func _calculate_positions():
	"""Tính toán các vị trí di chuyển"""
	positions = [start_position]
	positions.append(start_position + Vector2(0, -distances[0]))      # up
	positions.append(positions[1] + Vector2(-distances[1], 0))        # left
	positions.append(positions[2] + Vector2(0, distances[2]))         # down

func _on_trigger_entered(body):
	# Chỉ trigger khi platform active và chưa triggered
	if body.is_in_group("player") and not triggered and is_active:
		print("Player triggered active platform movement!")
		triggered = true
		_move_sequence()

# ✅ ĐƯỢC GỌI TỪ ACTIVATIONZONE
func activate_platform():
	"""Được gọi từ ActivationZone - BẬT chức năng platform"""
	is_active = true
	print("Platform activated (enabled): ", name)

# ✅ TẮT PLATFORM
func deactivate_platform():
	"""Tắt chức năng platform"""
	is_active = false
	print("Platform deactivated (disabled): ", name)

func _move_sequence():
	"""Di chuyển theo sequence với delay"""
	print("Starting platform movement sequence")
	if current_tween:
		current_tween.kill()
	
	current_tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	
	# Di chuyển qua 3 bước: UP → LEFT → DOWN
	for i in range(3):
		# Delay TRƯỚC khi di chuyển
		if delays[i] > 0:
			current_tween.tween_interval(delays[i])
			print("  Waiting ", delays[i], "s before step ", i + 1)
		
		# Di chuyển đến vị trí
		current_tween.tween_property(self, "global_position", positions[i + 1], speeds[i])
		
		match i:
			0:
				print("  Step 1: Moving UP ", distances[0], " pixels")
			1:
				print("  Step 2: Moving LEFT ", distances[1], " pixels")
			2:
				print("  Step 3: Moving DOWN ", distances[2], " pixels")
	
	current_tween.tween_callback(func():
		print("Platform movement sequence completed!")
		current_tween = null
	)

func reset_platform():
	"""Reset platform về vị trí ban đầu"""
	print("Resetting platform to start position")
	
	if current_tween:
		current_tween.kill()
		current_tween = null
	
	global_position = start_position
	triggered = false
	# Không reset is_active - giữ nguyên trạng thái activation
	
	print("Platform reset - Active state preserved: ", is_active)
