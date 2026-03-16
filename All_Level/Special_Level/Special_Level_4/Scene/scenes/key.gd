extends Area2D


func _on_body_entered(body):

	if body.is_in_group("Player"):

		print("Key picked!")

		var checkpoint = get_tree().get_first_node_in_group("checkpoint")
		if checkpoint:
			checkpoint.monitoring = true

		queue_free()
