extends TextureButton


@onready var player = get_tree().get_first_node_in_group("Player")

func _on_attack_button_pressed():
	if player:
		player.attack()
