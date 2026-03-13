extends CharacterBody2D

signal update_hp_bar(hp_bar_value: int)

enum State {
	IDLE,
	RUN,
	ATTACK,
	DIED
}

var look_direction: Vector2 = Vector2.DOWN
@onready var joystick = $"../../UI/Control/Joystick/Knob"


@export_category("Stats")
@export	var speed: int = 400
@export var attack_damage: int = 60
@export var hitpoints: int = 150


var state: State = State.IDLE
var move_direction: Vector2 = Vector2(0,0)
var attack_speed: float
var hitpoints_max: int
var is_dying: bool = false
var spawn_position: Vector2
var base_speed: int
var base_damage: int

#@onready var arrow = $Arrow
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_playback: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]


func _ready() -> void:
	hitpoints_max = hitpoints
	spawn_position = global_position
	base_speed = speed
	base_damage = attack_damage
	animation_tree.set_active(true)
	calculate_stats()


func respawn():

	print("Respawning player")

	global_position = spawn_position
	hitpoints = hitpoints_max
	update_hp_bar.emit(100)

	# reset stats
	speed = base_speed
	attack_damage = base_damage

	state = State.IDLE
	is_dying = false

	velocity = Vector2.ZERO

	set_physics_process(true)

	animation_playback.travel("idle")


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		attack()

func _physics_process(delta: float) -> void:
	if state != State.ATTACK:
		movement_loop()

	update_look_direction()


func calculate_stats() -> void:
	attack_speed = Equations.calculate_attack_speed() 
	var time_factor: float = Equations.BASE_ATTACK_SPEED / attack_speed
	animation_tree.set("parameters/attack/TimeScale/scale", time_factor)
	print("New attack speed:" , attack_speed)


func movement_loop() -> void:
	var keyboard_dir = Vector2(
	int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left")),
	int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("jump"))
	)

	if joystick.current_direction != Vector2.ZERO:
		move_direction = joystick.current_direction
	else:
		move_direction = keyboard_dir

	var motion: Vector2 = move_direction.normalized() * speed
	set_velocity(motion)
	move_and_slide()
	
	# Sprite flipping (only in idle/run)
	if state == State.IDLE or state == State.RUN:
		if move_direction.x < -0.01:
			$Sprite2D.flip_h = true
		elif move_direction.x > 0.01:
			$Sprite2D.flip_h = false
	
	if motion != Vector2.ZERO and state == State.IDLE:
		state = State.RUN
		update_animation()
	elif motion == Vector2.ZERO and state == State.RUN:
		state = State.IDLE
		update_animation()

func update_animation() -> void:
	match state:
		State.IDLE:
			animation_playback.travel("idle")
		State.RUN:
			animation_playback.travel("run")
		State.ATTACK:
			animation_playback.travel("attack")

func attack() -> void:
	# Verify the player is not already attacking, and set the player state
	if state == State.ATTACK:
		return
	state = State.ATTACK
	
	# Find the attack direction and push to animationTree blendspace2d
	var attack_dir = look_direction.normalized()
	$Sprite2D.flip_h = attack_dir.x < 0 and abs(attack_dir.x) >= abs(attack_dir.y)
	animation_tree.set("parameters/attack/BlendSpace2D/blend_position",attack_dir)
	update_animation()
	
	#Return the player state after attack has finished
	await get_tree().create_timer(attack_speed).timeout
	state = State.IDLE


func take_damage(damage_taken: int) -> void:
	hitpoints = max(0, hitpoints - damage_taken)
	@warning_ignore("integer_division")
	update_hp_bar.emit((hitpoints * 100) / hitpoints_max)

	if hitpoints <= 0:
		death()


func death() -> void:

	if is_dying:
		return

	is_dying = true
	state = State.DIED

	print("Player died")

	velocity = Vector2.ZERO
	set_physics_process(false)

	# báo GameManager tăng số lần chết
	GameManager.increment_death_count()

	var effects_ui = get_tree().get_first_node_in_group("effects_ui")
	if effects_ui:
		effects_ui.clear_effects()

	respawn()

	var game = get_tree().get_first_node_in_group("game_scene")
	if game:
		game.reset_player_progress()
		game.reset_level()


func _on_hit_box_area_entered(area: Area2D) -> void:

	if state != State.ATTACK:
		return

	if area.owner.has_method("take_damage"):
		area.owner.take_damage(attack_damage)


func update_look_direction():
	if joystick.current_direction != Vector2.ZERO:
		look_direction = joystick.current_direction.normalized()
	elif move_direction != Vector2.ZERO:
		look_direction = move_direction.normalized()


func heal(amount:int):
	hitpoints = min(hitpoints + amount, hitpoints_max)
	update_hp_bar.emit((hitpoints * 100) / hitpoints_max)


func apply_temp_buff(stat:String, value:int, duration:float):

	var effects_ui = get_tree().get_first_node_in_group("effects_ui")

	var effect_name = stat

	if value > 0:
		effect_name += "_buff"
	else:
		effect_name += "_debuff"

	if effects_ui:
		effects_ui.add_effect(effect_name, duration)

	match stat:
		"speed":
			speed += value
		"damage":
			attack_damage += value

	await get_tree().create_timer(duration).timeout

	if not is_inside_tree() or is_dying:
		return

	match stat:
		"speed":
			speed -= value
			speed = max(50, speed)

		"damage":
			attack_damage -= value
			attack_damage = max(1, attack_damage)


func take_random_damage():
	var dmg = randi_range(10,60)
	if hitpoints - dmg <= 1:
		dmg = hitpoints - 1
	take_damage(dmg)


func gain_experience(exp_amount:int):
	var game = get_tree().get_first_node_in_group("game_scene")
	if game:
		game.experience_gained(exp_amount)
