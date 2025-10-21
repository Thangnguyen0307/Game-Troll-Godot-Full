extends AnimatableBody2D

@export var speed: float = 888.8
@export var direction: int = -1

var triggered: bool = false
var start_position: Vector2

func _ready():
	start_position = global_position
	visible = true

func _physics_process(delta: float) -> void:
	if triggered:
		global_position.x += direction * speed * delta
		visible = true
	if global_position.x < -7.7: #đến đoạn này thì chữ sẽ dừng lại và vẫn hiện đó 
		#global_position.x = 0
		triggered = false
		

func _on_saw_trigger_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("Saw activated!")
		triggered = true

func reset_trap():
	global_position = start_position
	triggered = false
