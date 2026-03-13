extends CharacterBody2D

const ITEM_BOX = preload("res://All_Level/Special_Level/Special_Level_4/Scene/scenes/mystery_box.tscn")

signal died(exp:int)

enum State {
	IDLE,
	CHASE,
	RETURN,
	ATTACK,
	DEAD
}

@export_category("Stats")
@export var speed: int = 128
@export var attack_damage: int = 10
@export var attack_speed: float = 1.8
@export var hitpoints: int = 180
@export var aggro_range: float = 256.8
@export var attack_range: float = 80.8
@export var exp_reward: int = 600
@export var item_drop_rate: float = 1
@export_category("Related Scenes")
@export var death_packed: PackedScene

var state: State = State.IDLE

@onready var spawn_point: Vector2 = global_position
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_playback: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("Player")
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var health_bar: ProgressBar = $HealthBar

func _ready() -> void:
	animation_tree.set_active(true)
	health_bar.max_value = hitpoints
	health_bar.value = hitpoints

func _physics_process(delta: float) -> void:
	if state == State.DEAD:
		return
	if state == State.ATTACK:
		return
	if distance_to_player() <= attack_range:
		state = State.ATTACK
		attack()
	elif distance_to_player() < aggro_range:
		state = State.CHASE
		move()
	elif global_position.distance_to(spawn_point) > 32:
		state = State.RETURN
		move()
	elif state != State.IDLE:
		state = State.IDLE
		update_animation() 


func distance_to_player() -> float:
	return global_position.distance_to(player.global_position)


func move() -> void:
	if state == State.CHASE:
		nav_agent.target_position = player.global_position
	elif state == State.RETURN:
		nav_agent.target_position = spawn_point
	var next_path_position: Vector2 = nav_agent.get_next_path_position()
	velocity = global_position.direction_to(next_path_position) * speed

	if nav_agent.avoidance_enabled:
		nav_agent.set_velocity(velocity)
	else:
		_on_navigation_agent_2d_velocity_computed(velocity)
	move_and_slide()

	# Sprite flipping (only in idle/run)
	if state == State.IDLE or state == State.CHASE:
		if velocity.x < -0.01:
			$Sprite2D.flip_h = true
		elif velocity.x > 0.01:
			$Sprite2D.flip_h = false
	
	# update animation
	update_animation()


func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	nav_agent.velocity = safe_velocity


func update_animation() -> void:
	match state:
		State.IDLE:
			animation_playback.travel("idle")
		State.CHASE:
			animation_playback.travel("run")
		State.RETURN:
			animation_playback.travel("run")
		State.ATTACK:
			animation_playback.travel("attack")


func attack() -> void:
	var player_pos: Vector2 = player.global_position
	var attack_dir: Vector2 = (player_pos - global_position).normalized()
	$Sprite2D.flip_h = attack_dir.x < 0 and abs(attack_dir.x) >= abs(attack_dir.y)
	animation_tree.set("parameters/attack/BlendSpace2D/blend_position", attack_dir)
	update_animation()

	await get_tree().create_timer(attack_speed).timeout
	state = State.IDLE


func take_damage(damage_taken: int) -> void:
	if state == State.DEAD:
		return
		
	hitpoints -= damage_taken
	hitpoints = clamp(hitpoints, 0, health_bar.max_value)
	
	health_bar.value = hitpoints
	
	if hitpoints <= 0:
		state = State.DEAD
		death()

func death() -> void:
	died.emit(exp_reward)

	if randf() < item_drop_rate:
		spawn_item()

	var death_scene: Node2D = death_packed.instantiate()
	death_scene.position = global_position + Vector2(0.0, -32.0)

	var effects_node = get_tree().get_first_node_in_group("effects")
	if effects_node:
		effects_node.call_deferred("add_child", death_scene)

	call_deferred("queue_free")


func _on_hit_box_area_entered(area: Area2D) -> void:

	if state != State.ATTACK:
		return

	if area.owner.has_method("take_damage"):
		area.owner.take_damage(attack_damage)


func spawn_item():
	var item = ITEM_BOX.instantiate()

	item.global_position = global_position + Vector2(
		randf_range(-20,20),
		randf_range(-20,20)
	)

	var items_node = get_tree().get_first_node_in_group("mystery_pickups")

	if items_node:
		items_node.call_deferred("add_child", item)
