extends CharacterBody2D

const SPEED = 600   # tốc độ rơi
var triggered = false 
var start_position: Vector2

func _ready():
	start_position = global_position

func _physics_process(delta: float) -> void:
	if triggered:
		velocity.y = SPEED   # rơi xuống
	else:
		velocity = Vector2.ZERO   # đứng yên khi chưa trigger

	move_and_slide()

func _on_trigger_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):   # chỉ rơi khi player đi vào
		triggered = true

func reset_trap():
	global_position = start_position
	velocity = Vector2.ZERO
	triggered = false
