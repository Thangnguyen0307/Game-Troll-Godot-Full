extends Node2D

signal levelup

@export var enemies_to_kill: int = 10000
@export var key_scene: PackedScene

@onready var HUB: Control = $UI/HUB

var killed_enemies: int = 0

func _ready() -> void:
	var player: CharacterBody2D = get_tree().get_first_node_in_group("Player")

	levelup.connect(player.calculate_stats)
	levelup.connect(HUB.update_level_indicator)

	player.update_hp_bar.connect(HUB.update_hp_bar)
	# connect enemy spawner
	var spawner = get_tree().get_first_node_in_group("enemy_spawner")
	if spawner:
		spawner.enemy_killed.connect(_on_enemy_killed)


func experience_gained(exp_gain: int) -> void:
	if PlayerData.level == LevelData.MAX_LEVEL:
		return

	PlayerData.experience += exp_gain

	if PlayerData.experience < 0:
		PlayerData.experience = 0

	while PlayerData.level < LevelData.MAX_LEVEL and PlayerData.experience >= LevelData.LEVEL_THRESHOLDS[PlayerData.level - 1]:

		PlayerData.experience -= LevelData.LEVEL_THRESHOLDS[PlayerData.level - 1]
		PlayerData.level += 1

		print("LEVEL UP → ", PlayerData.level)

		levelup.emit()


func _on_enemy_killed():

	killed_enemies += 1

	print("Killed:", killed_enemies, "/", enemies_to_kill)

	if killed_enemies >= enemies_to_kill:
		unlock_checkpoint()


func unlock_checkpoint():

	print("Objective completed!")

	# 1 stop enemy spawn
	var spawner = get_tree().get_first_node_in_group("enemy_spawner")
	if spawner:
		spawner.stop_spawning()

	# 2 remove wood sign
	var sign = get_tree().get_first_node_in_group("wood_sign")
	if sign:
		sign.queue_free()

	# 3 drop key
	if key_scene:
		var key = key_scene.instantiate()

		var player = get_tree().get_first_node_in_group("Player")
		if player:
			key.global_position = player.global_position

		var items = get_tree().get_first_node_in_group("mystery_pickups")
		if items:
			items.add_child(key)

	# 4 enable checkpoint
	var checkpoint = get_tree().get_first_node_in_group("checkpoint")
	if checkpoint:
		checkpoint.monitoring = true


func reset_level():

	var spawner = get_tree().get_first_node_in_group("enemy_spawner")
	if spawner:
		spawner.reset_enemies()

func reset_player_progress():

	PlayerData.level = 1
	PlayerData.experience = 0

	HUB.update_level_indicator()
