extends AnimatableBody2D

var triggered: bool = false
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	visible = false
	if collision_shape_2d:
			# Dùng call_deferred để đảm bảo nó được tắt sau khi mọi thứ đã sẵn sàng
			collision_shape_2d.call_deferred("set_disabled", true)
			
func _physics_process(delta: float) -> void:
	if triggered:
		visible = true
		collision_shape_2d.call_deferred("set_disabled", false)
		

func _on_saw_trigger_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("Box activated!")
		triggered = true
		visible = true

func reset_trap():
	triggered = false
	_ready()
