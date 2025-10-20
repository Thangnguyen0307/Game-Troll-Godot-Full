extends Area2D

@export var checkpoint_node: NodePath
@export var teleport_node: NodePath
@export var checkpoint_new_pos: Vector2 = Vector2(26, 678)
@export var fade_out_time: float = 0.4
@export var fade_in_time: float = 0.4

var checkpoint: Node2D
var teleport: Node2D
var has_triggered: bool = false

func _ready():
	checkpoint = get_node_or_null(checkpoint_node)
	teleport = get_node_or_null(teleport_node)

	if teleport:
		teleport.visible = false
		teleport.modulate.a = 0.0  # ẩn hoàn toàn ban đầu
		if teleport.has_method("set_collision_layer_value"):
			teleport.set_collision_layer_value(1, false)

	body_entered.connect(_on_body_entered)


func _on_body_entered(body):
	if not body or not body.is_in_group("player"):
		return
	if has_triggered:
		return
	
	if checkpoint and teleport:
		# 1️⃣ Checkpoint fade out
		var tween = create_tween()
		tween.tween_property(checkpoint, "modulate:a", 0.0, fade_out_time)

		# 2️⃣ Khi fade xong → checkpoint "dịch chuyển tức thời"
		tween.tween_callback(func ():
			checkpoint.global_position = checkpoint_new_pos
			checkpoint.modulate.a = 1.0  # hiện lại sau khi đã đến chỗ mới

			# 3️⃣ Teleport chỉ fade-in, không đổi vị trí
			teleport.visible = true
			if teleport.has_method("set_collision_layer_value"):
				teleport.set_collision_layer_value(1, true)
			
			var fade_tween = create_tween()
			fade_tween.tween_property(teleport, "modulate:a", 1.0, fade_in_time)
		)
	
	has_triggered = true
