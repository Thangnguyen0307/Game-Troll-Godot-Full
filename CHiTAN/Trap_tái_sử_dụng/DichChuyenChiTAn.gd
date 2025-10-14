extends AnimatableBody2D

@export var move_up_distance: float = 63.0
@export var move_left_distance: float = 100.0
@export var move_down_distance: float = 63.0
@export var move_speed: float = 0.1

# Teleport settings
@export_group("Teleport")
@export var teleport_target: Vector2 = Vector2.ZERO
@export var teleport_offset: Vector2 = Vector2(0, -10)

@export_group("Activation")
@export var is_active: bool = false  # ✅ KIỂM SOÁT KHI NÀO PLATFORM HOẠT ĐỘNG

var start_position: Vector2
var current_step: int = 0
var move_positions: Array[Vector2] = []
var has_triggered = false
var is_moving = false
var current_tween: Tween

@onready var trigger_area = $TriggerArea
@onready var teleport_area = $MapChiTan2

func _ready():
	start_position = global_position
	
	var pos_after_up = start_position + Vector2(0, -move_up_distance)
	var pos_after_left = pos_after_up + Vector2(-move_left_distance, 0)
	var pos_final = pos_after_left + Vector2(0, move_down_distance)
	
	move_positions = [pos_after_up, pos_after_left, pos_final]
	
	if trigger_area:
		trigger_area.body_entered.connect(_on_trigger_entered)
	
	if teleport_area:
		teleport_area.body_entered.connect(_on_teleport_entered)
	
	add_to_group("moving_platforms")
	connect_to_player_death()
	
	print("MovingPlatform ready - is_active: ", is_active)

func connect_to_player_death():
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_signal("player_died"):
		player.player_died.connect(_on_player_died)

# ✅ CHỈ TRIGGER KHI is_active = true
func _on_trigger_entered(body):
	if body.is_in_group("player") and not has_triggered and is_active:
		print("Platform movement triggered!")
		has_triggered = true
		move_platform()

# ✅ CHỈ TELEPORT KHI is_active = true
func _on_teleport_entered(body):
	if body.is_in_group("player") and is_active:
		body.global_position = teleport_target + teleport_offset
		print("Player teleported to: ", teleport_target)

# ✅ ĐƯỢC GỌI TỪ ACTIVATIONZONE
func activate_platform():
	is_active = true
	print("Platform activated: ", name)

func _on_player_died():
	print("Player died - resetting platform and activation zones!")
	reset_platform()
	reset_all_activation_zones()

func reset_all_activation_zones():
	"""Reset tất cả ActivationZone trong scene"""
	var activation_zones = get_tree().get_nodes_in_group("activation_zones")
	for zone in activation_zones:
		if zone.has_method("reset_zone"):
			zone.reset_zone()

func move_platform():
	if is_moving or current_step >= move_positions.size():
		return
		
	is_moving = true
	var target = move_positions[current_step]
	
	if current_tween:
		current_tween.kill()
	
	current_tween = create_tween()
	current_tween.tween_property(self, "global_position", target, move_speed)
	current_tween.tween_callback(func(): 
		is_moving = false
		current_step += 1
		
		if current_step < move_positions.size():
			await get_tree().create_timer(0.2).timeout
			move_platform()
		else:
			current_tween = null
	)

func reset_platform():
	if current_tween:
		current_tween.kill()
		current_tween = null
	
	global_position = start_position
	has_triggered = false
	is_moving = false
	current_step = 0
	is_active = false  # ✅ RESET ACTIVE STATE
	
	print("Platform reset complete!")
