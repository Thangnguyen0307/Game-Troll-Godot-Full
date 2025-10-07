extends Area2D

@export var move_distance: float = 45.0
@export var move_speed: float = 0.2

var start_position: Vector2
var target_position: Vector2
var has_triggered = false

func _ready():
	start_position = global_position
	target_position = start_position + Vector2(move_distance, 0)

	if has_node("TriggerArea"):
		$TriggerArea.body_entered.connect(_on_player_touch_trigger)
	body_entered.connect(_on_player_touch_deadly)

	# Ẩn trap cho đến khi bị trigger
	
	print("Trap ready at: ", global_position)


func _on_player_touch_deadly(body):
	if body.name.begins_with("CharacterBody2D"):
		print("☠️ Player touched deadly area!")
		if body.has_method("die"):
			body.die()
		
		# Ngay sau khi giết Player → reset chính trap này
		reset_object()


func _on_player_touch_trigger(body):
	if body.name.begins_with("CharacterBody2D") and not has_triggered:
		print("▶️ Player triggered movement!")
		has_triggered = true
		show()
		move_object()


func move_object():
	print("➡️ Moving object...")
	var tween = create_tween()
	tween.tween_property(self, "global_position", target_position, move_speed)


func reset_object():
	print("🔄 Reset trap to start position")
	global_position = start_position
	has_triggered = false
	
