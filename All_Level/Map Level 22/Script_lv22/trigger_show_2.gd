extends Area2D

@export var gai_parent: Node2D
@export var player_group: String = "player"

@export var trigger2_rise_distance: float = -50.0
@export var trigger2_rise_duration: float = 0.4
@export var spike_rise_distance: float = -13.0
@export var spike_rise_duration: float = 0.03
@export var delay_between_spikes: float = 0.098
@export var return_after: float = 1.0
@export var return_duration: float = 0.2

var _triggered := false
var _original_positions := {}
var _original_pos_trigger: Vector2
var _player = null
var _prev_alive_state := true


func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	_original_pos_trigger = position

	if gai_parent:
		for child in gai_parent.get_children():
			if child is Area2D:
				_original_positions[child] = child.position

	_player = get_tree().get_first_node_in_group(player_group)
	if _player:
		if _player.has_signal("player_died"):
			_player.player_died.connect(_on_player_died)
		elif _player.has_method("is_alive"):
			_prev_alive_state = _player.is_alive


func _process(_delta):
	if _player and not _player.has_signal("player_died"):
		if _prev_alive_state and _player.is_alive == false:
			_on_player_died()
		_prev_alive_state = _player.is_alive


# 🟩 Hàm được Trigger1 gọi
func rise_from_ground():
	print_debug("Trigger2: Trồi lên mặt đất")
	var tween = create_tween()
	tween.tween_property(self, "position", _original_pos_trigger + Vector2(0, trigger2_rise_distance), trigger2_rise_duration)
	await tween.finished
	print_debug("Trigger2: Hoàn thành trồi lên")


func _on_body_entered(body):
	if _triggered or not body.is_in_group(player_group):
		return
	_triggered = true
	print_debug("Trigger2: Player chạm, bắt đầu trồi gai")
	_start_spike_sequence()


func _start_spike_sequence():
	if not gai_parent:
		return

	for child in gai_parent.get_children():
		if child is Area2D:
			var original_pos = _original_positions[child]
			var tween = create_tween()
			tween.tween_property(child, "position", original_pos + Vector2(0, spike_rise_distance), spike_rise_duration)
			tween.tween_callback(Callable(self, "_schedule_return").bind(child, original_pos))
			await get_tree().create_timer(delay_between_spikes).timeout


func _schedule_return(child: Area2D, original_pos: Vector2):
	await get_tree().create_timer(return_after).timeout
	var tween = create_tween()
	tween.tween_property(child, "position", original_pos, return_duration)


func _on_player_died():
	reset_trigger()


func reset_trigger():
	print_debug("Trigger2 reset")
	_triggered = false
	position = _original_pos_trigger
	if gai_parent:
		for child in gai_parent.get_children():
			if child is Area2D and _original_positions.has(child):
				child.position = _original_positions[child]
