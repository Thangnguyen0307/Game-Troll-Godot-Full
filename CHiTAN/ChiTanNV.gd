extends CharacterBody2D

const SPEED = 280.0
const JUMP_VELOCITY = -430.0
@onready var sprite_2d: AnimatedSprite2D = $Sprite2D

var is_alive = true
var spawn_point: Vector2
var original_scale: Vector2
var size_tween: Tween
var size_timer: Timer

func _ready() -> void:
	spawn_point = global_position
	original_scale = scale
	add_to_group("player")

func _physics_process(delta: float) -> void:
	if not is_alive: return
	
	# Movement & Animation
	var direction = Input.get_axis("left", "right")
	velocity.x = direction * SPEED if direction else move_toward(velocity.x, 0, 15)
	sprite_2d.flip_h = velocity.x < 0
	
	# Gravity & Jump
	if not is_on_floor():
		velocity += get_gravity() * delta
		sprite_2d.animation = "Jumping"
	elif Input.is_action_just_pressed("jump"):
		$"/root/AudioController".play_jump()
		velocity.y = JUMP_VELOCITY
	
	# Ground animations & sound
	if is_on_floor():
		if abs(velocity.x) > 1:
			sprite_2d.animation = "Running"
			$"/root/AudioController".play_walk()
		else:
			sprite_2d.animation = "Idle"
			$"/root/AudioController".stop_walk()
	
	move_and_slide()

func die():
	GameManager.increment_death_count()
	is_alive = false
	sprite_2d.play("Hit")
	await get_tree().create_timer(1.0).timeout
	_reset()

func _reset():
	$"/root/AudioController".play_respawn()
	global_position = spawn_point
	is_alive = true
	_reset_size()
	_reset_objects()

func _reset_size():
	if size_tween: size_tween.kill()
	if size_timer: size_timer.queue_free()
	scale = original_scale

func _reset_objects():
	for group in ["resettable_traps", "moving_platforms", "activation_zones", "fruits", "resetable"]:
		for obj in get_tree().get_nodes_in_group(group):
			var method = "reset_object" if group == "resettable_traps" else ("reset_platform" if group == "moving_platforms" else ("reset_zone" if group == "activation_zones" else ("reset_fruit" if group == "fruits" else "reset")))
			if obj.has_method(method): obj.call(method)

func change_size(multiplier: float, duration: float = 1.0, permanent: bool = true, temp_duration: float = 5.0):
	if size_tween: size_tween.kill()
	if size_timer: size_timer.queue_free()
	
	size_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	size_tween.tween_property(self, "scale", original_scale * multiplier, duration)
	
	if not permanent:
		size_timer = Timer.new()
		add_child(size_timer)
		size_timer.wait_time = temp_duration
		size_timer.one_shot = true
		size_timer.timeout.connect(_reset_size)
		size_timer.start()

func is_on_moving_platform() -> bool:
	for i in get_slide_collision_count():
		if get_slide_collision(i).get_collider().is_in_group("moving_platforms"):
			return true
	return false

func get_current_platform(): 
	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider()
		if collider.is_in_group("moving_platforms"): return collider
	return null

func _on_hurt_box_area_entered(area: Area2D) -> void:
	if area.is_in_group("hurt"): die()
