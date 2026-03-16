extends Node2D

signal levelup

@export var enemies_to_kill: int = 10000
@export var key_scene: PackedScene

@onready var HUB: Control = $UI/HUB

var killed_enemies: int = 0
var sign_base_text: String = ""

func _ready() -> void:
	var player: CharacterBody2D = get_tree().get_first_node_in_group("Player")

	levelup.connect(player.calculate_stats)
	levelup.connect(HUB.update_level_indicator)

	player.update_hp_bar.connect(HUB.update_hp_bar)
	# connect enemy spawner
	var spawner = get_tree().get_first_node_in_group("enemy_spawner")
	if spawner:
		spawner.enemy_killed.connect(_on_enemy_killed)
	# lấy text gốc của bảng
	var sign = get_tree().get_first_node_in_group("wood_sign")
	if sign:
		var label = sign.get_node("Sign_Board/Label")
		sign_base_text = label.text



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

	update_sign_label()

	if killed_enemies >= enemies_to_kill:
		unlock_checkpoint()


func unlock_checkpoint():

	print("Objective completed!")

	# dừng spawn
	var spawner = get_tree().get_first_node_in_group("enemy_spawner")
	if spawner:
		spawner.stop_spawning()

	# phá bảng gỗ
	var sign = get_tree().get_first_node_in_group("wood_sign")
	if sign:
		sign.break_sign()


func update_sign_label():

	var sign = get_tree().get_first_node_in_group("wood_sign")

	if sign:
		var label = sign.get_node("Sign_Board/Label")

		# chưa giết quái nào → giữ nguyên text gốc
		if killed_enemies == 0:
			label.text = sign_base_text
		else:
			label.text = sign_base_text + "\n\nKill: " + str(killed_enemies) + " / " + str(enemies_to_kill)


func reset_level():

	var spawner = get_tree().get_first_node_in_group("enemy_spawner")
	if spawner:
		spawner.reset_enemies()

func reset_player_progress():

	PlayerData.level = 1
	PlayerData.experience = 0

	HUB.update_level_indicator()


func _input(event):

	if event is InputEventKey and event.pressed:

		# debug: gần đủ quái
		if event.keycode == KEY_J:

			killed_enemies = enemies_to_kill - 1

			print("DEBUG: Almost complete objective")

			update_sign_label()


		# debug: hoàn thành luôn
		if event.keycode == KEY_K:

			print("DEBUG: Force complete objective")

			killed_enemies = enemies_to_kill
			unlock_checkpoint()
