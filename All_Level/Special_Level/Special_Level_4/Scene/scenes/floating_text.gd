extends Node2D

@onready var label = $Label

var float_speed = 30
var life_time = 2

func setup(text, color):

	label.text = text
	label.modulate = color

	await get_tree().create_timer(life_time).timeout
	queue_free()


func _process(delta):

	position.y -= float_speed * delta
	modulate.a -= delta
