extends Area2D

@export var speed: float = 600.0
@export var direction: int = 1   # 1 = sang phải, -1 = sang trái
@export var limit: float = 1200  # giới hạn vị trí để tắt trap

var triggered: bool = false
var start_position: Vector2

func _ready():
	# Ẩn trap lúc bắt đầu
	hide()
	start_position = global_position

func _physics_process(delta: float) -> void:
	if triggered:
		# Chỉ hiện trap khi được kích hoạt
		show()
		global_position.x += direction * speed * delta

		# Kiểm tra nếu trap vượt quá giới hạn
		if (direction == 1 and global_position.x > limit) or \
		   (direction == -1 and global_position.x < limit):
			hide()
			set_physics_process(false)

func _on_saw_trigger_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("Saw activated!")
		triggered = true

func reset_trap():
	# Quay về vị trí ban đầu và ẩn trap
	global_position = start_position
	triggered = false
	hide()
	set_physics_process(true)
