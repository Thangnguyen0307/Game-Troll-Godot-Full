extends Area2D

@export_group("Movement")
@export var distances: Array[float] = [90.0, 90.0, 150.0, 150.0]  # [down, up, left, right]
@export var speeds: Array[float] = [0.5, 0.3, 0.8, 0.2]           # [down, up, left, right]
@export var delays: Array[float] = [0.0, 0.0, 0.0, 0.0]           # [after_down, after_up, after_left, after_right]

var start_pos: Vector2
var positions: Array[Vector2]
var triggered = false
var tween: Tween

func _ready():
	start_pos = global_position
	_calculate_positions()
	body_entered.connect(_on_deadly_touch)
	$TriggerArea.body_entered.connect(_on_trigger)
	add_to_group("resettable_traps")

func _calculate_positions():
	positions = [start_pos]
	positions.append(start_pos + Vector2(0, distances[0]))           # down
	positions.append(positions[1] + Vector2(0, -distances[1]))       # up
	positions.append(positions[2] + Vector2(-distances[2], 0))       # left  
	positions.append(positions[3] + Vector2(distances[3], 0))        # right

func _on_deadly_touch(body):
	if body.is_in_group("player"):
		body.die()
		reset_object()

func _on_trigger(body):
	if body.is_in_group("player") and not triggered:
		triggered = true
		_move_sequence()

func _move_sequence():
	if tween: tween.kill()
	tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	
	for i in range(4):
		tween.tween_property(self, "global_position", positions[i + 1], speeds[i])
		if delays[i] > 0: tween.tween_delay(delays[i])
	
	tween.tween_callback(func(): tween = null)

func reset_object():
	if tween: tween.kill()
	global_position = start_pos
	triggered = false
