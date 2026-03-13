extends Node2D

signal enemy_killed

@export var enemy_scene: PackedScene
@export var max_enemies: int = 5
@export var respawn_time: float = 10.0


@onready var spawn_points: Array = get_children()
@onready var enemies_node: Node2D = $"../Enemies"

var current_enemies: int = 0
var spawning_enabled: bool = true

func _ready():
	for spawn_point in spawn_points:
		spawn_enemy(spawn_point)


func spawn_enemy(spawn_point):
	if not spawning_enabled:
		return

	if current_enemies >= max_enemies:
		return

	var enemy = enemy_scene.instantiate()

	var angle = randf_range(0, TAU)
	var radius = randf_range(50, 100)
	var offset = Vector2(cos(angle), sin(angle)) * radius

	enemy.global_position = spawn_point.global_position + offset

	enemies_node.add_child(enemy)

	current_enemies += 1

	enemy.died.connect(_on_enemy_died.bind(spawn_point))


func _on_enemy_died(exp, spawn_point):
	current_enemies -= 1
	enemy_killed.emit()
	respawn_enemy(spawn_point)


func respawn_enemy(spawn_point):
	await get_tree().create_timer(respawn_time).timeout

	if spawning_enabled:
		spawn_enemy(spawn_point)


func stop_spawning():
	spawning_enabled = false


func reset_enemies():

	for e in enemies_node.get_children():
		e.queue_free()

	current_enemies = 0
	spawning_enabled = true

	await get_tree().process_frame

	for spawn_point in spawn_points:
		spawn_enemy(spawn_point)
