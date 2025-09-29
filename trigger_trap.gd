extends Node2D  # hoặc StaticBody2D/KinematicBody2D tùy bạn

var move_up = false
var speed = 200

func move_spikes_up():
	move_up = true

func _physics_process(delta):
	if move_up:
		position.y -= speed * delta  # Di chuyển lên
