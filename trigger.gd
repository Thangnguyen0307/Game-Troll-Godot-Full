extends Area2D

@export var spike_path: NodePath  # đường dẫn tới bẫy gai
var spike

func _ready():
	spike = get_node(spike_path)

func _on_body_entered(body):
	if body.is_in_group("Player"):  # hoặc check tên body
		spike.reverse_direction()
