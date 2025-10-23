extends Area2D

var triggered: bool = false
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D
@onready var sprite_2d: AnimatedSprite2D = $Sprite2D

func _ready():
	visible = false
	if collision_shape_2d:
			# Dùng call_deferred để đảm bảo nó được tắt sau khi mọi thứ đã sẵn sàng
			collision_shape_2d.call_deferred("set_disabled", true)

func _physics_process(delta: float) -> void:
	if triggered:
		visible = true
		sprite_2d.animation = "default"
		collision_shape_2d.call_deferred("set_disabled", false)

func _on_saw_trigger_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("Spike activated!")
		triggered = true

func reset_trap():
	sprite_2d.animation = "default"
	await get_tree().create_timer(1.0).timeout
	triggered = false
	visible = false
	_ready()
