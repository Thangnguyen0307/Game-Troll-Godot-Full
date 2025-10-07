extends Area2D

@export var speed: float = 300.0
@export var direction: int = -1
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D
@onready var sprite_2d: AnimatedSprite2D = $Sprite2D

var triggered: bool = false
var start_position: Vector2

func _ready():
	start_position = global_position
	visible = false
	if collision_shape_2d:
			# Dùng call_deferred để đảm bảo nó được tắt sau khi mọi thứ đã sẵn sàng
			collision_shape_2d.call_deferred("set_disabled", true)

func _physics_process(delta: float) -> void:
	if triggered:
		sprite_2d.animation = "default"
		global_position.x += direction * speed * delta
		collision_shape_2d.call_deferred("set_disabled", false)
		visible = true
	if global_position.x < 600:
		if collision_shape_2d:
			collision_shape_2d.call_deferred("set_disabled", true)
		visible = false
		print("Delete_fire")

func _on_saw_trigger_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("Spike activated!")
		triggered = true

func reset_trap():
	global_position = start_position
	triggered = false
	_ready()
