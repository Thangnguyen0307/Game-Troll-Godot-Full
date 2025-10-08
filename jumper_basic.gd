extends AnimatableBody2D

@export var speed: float = 500.0
@export var bounce_force: float = 800.0   # lực bắn Player lên (chỉnh tùy ý)

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var area: Area2D = $Area2D
@onready var collision: CollisionShape2D = $CollisionShape2D

var triggered: bool = false
var direction: int = 1
var is_active: bool = false

func _ready() -> void:

	# chắc chắn animation không tự phát ở lúc ban đầu
	if anim:
		anim.stop()

	# nối signal an toàn (chỉ khi area/anim tồn tại)
	if area:
		area.connect("body_entered", Callable(self, "_on_area_body_entered"))
	if anim:
		anim.connect("animation_finished", Callable(self, "_on_animation_finished"))



func activate() -> void:
	if not is_active:

		show()
# khi Area2D phát hiện body chạm
func _on_area_body_entered(body: Node) -> void:
	if body == null:
		return
	# chỉ tương tác khi là Player (theo group "Player")
	if not body.is_in_group("Player"):
		return

	# Nếu Player là CharacterBody2D thì set velocity trực tiếp
	if body is CharacterBody2D:
		# đặt vận tốc lên (âm trên trục Y để bay lên)
		body.velocity.y = -bounce_force
		# không cần gọi move_and_slide() ở đây — player sẽ xử lý trong _physics_process của chính nó

	# Nếu có AnimatedSprite2D thì play 1 vòng (chỉ play khi chưa đang chạy)
	if anim and not anim.is_playing():
		anim.play("hit")


# khi animation kết thúc -> dừng (giữ frame cuối)
func _on_animation_finished() -> void:
	if anim:
		anim.stop()
		
