extends Node2D

@export var key_scene: PackedScene
@export var max_hp: int = 600


@onready var hp_bar = $HPBar
@onready var board = $Sign_Board
@onready var particles = $BreakParticles

var hp: int
var activated: bool = false
var broken := false

func _ready():
	hp = max_hp
	hp_bar.max_value = max_hp
	hp_bar.value = hp
	hp_bar.visible = false
	$Hitbox.owner = self

func take_damage(dmg):

	hp -= dmg

	if !activated:
		activated = true
		hp_bar.visible = true

	hp_bar.value = hp

	if hp <= 0:
		break_sign()


func break_sign():
	if broken:
		return
	broken = true

	$Hitbox.set_deferred("monitoring", false)
	$Hitbox.set_deferred("monitorable", false)
	$Hitbox/CollisionShape2D.set_deferred("disabled", true)

	# ẩn bảng
	board.visible = false

	# phát hiệu ứng vỡ
	particles.emitting = true

	await get_tree().create_timer(0.2).timeout

	drop_key()


func drop_key():

	if key_scene == null:
		return

	var key = key_scene.instantiate()

	# spawn tại bảng
	key.global_position = global_position

	var items = get_tree().get_first_node_in_group("mystery_pickups")
	if items:
		items.add_child(key)

	# vị trí bay ra
	var target = global_position + Vector2(
		randf_range(-80, 80),   # bay ngang
		randf_range(40, 80)     # rơi xuống
	)

	# tween bay
	var tween = create_tween()
	tween.tween_property(key, "global_position", target, 0.4)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)
