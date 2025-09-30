extends Area2D
class_name Fruit

@export_group("Size Settings")
@export var scale_multiplier: float = 2.0
@export var is_shrinking: bool = false
@export var growth_duration: float = 2.0
@export var is_permanent: bool = true
@export var temporary_duration: float = 8.0

@export_group("Visual Effects")
@export var disappear_after_collect: bool = true
@export var play_sound: bool = true

var is_collected: bool = false
var tween: Tween

func _ready():
	body_entered.connect(_on_body_entered)
	add_to_group("fruits")

func _on_body_entered(body):
	if body.is_in_group("player") and not is_collected:
		is_collected = true
		if play_sound: $"/root/AudioController".play_click()  # Thay play_pickup() bằng play_click()
		_change_player_size(body)
		if disappear_after_collect: _hide_fruit()
func _change_player_size(player):
	if not player.has_method("change_size"): return
	var target = scale_multiplier if not is_shrinking else 1.0 / scale_multiplier
	player.change_size(target, growth_duration, is_permanent, temporary_duration)

func _hide_fruit():
	if tween: tween.kill()
	tween = create_tween()
	tween.parallel().tween_property(self, "scale", Vector2(0.1, 0.1), 0.3)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.3)
	await tween.finished
	queue_free()

func reset_fruit():
	is_collected = false
	visible = true
	scale = Vector2.ONE
	modulate = Color.WHITE
