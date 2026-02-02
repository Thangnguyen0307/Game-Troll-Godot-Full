extends CharacterBody2D

@export var speed :=300.0
@export var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var ghost_scene: PackedScene
@export var ghost_chance := 1
@export var sound_range := 550.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_body: CollisionShape2D = $CollisionBody
@onready var ray_left = $RayCastLeft
@onready var ray_right = $RayCastRight
@onready var killzone_collision = $Killzone/CollisionShape2D
@onready var spawn_sound: AudioStreamPlayer2D = $JumpScareAudio
@onready var sound_timer: Timer = $SoundTimer

var player_ref: CharacterBody2D
var was_activated := false
var direction := -1
var active := false
var start_position: Vector2

func _ready():
	start_position = global_position
	player_ref = get_tree().get_first_node_in_group("player")
	deactivate()

func activate():
	if was_activated:
		return

	speed = 300.0
	direction = -1
	was_activated = true
	active = true
	visible = true
	set_physics_process(true)

	collision_body.call_deferred("set_disabled", false)
	killzone_collision.call_deferred("set_disabled", false)

	if sound_timer:
		sound_timer.stop()
		
	print("speed là" +str(speed))

func deactivate():
	was_activated = false
	active = false
	visible = false
	set_physics_process(false)

	collision_body.call_deferred("set_disabled", true)
	killzone_collision.call_deferred("set_disabled", true)

	if spawn_sound:
		spawn_sound.stop()

	if sound_timer:
		sound_timer.stop()

	global_position = start_position
	velocity = Vector2.ZERO
	
	print("speed là" +str(speed))
	

func is_player_in_sound_range() -> bool:
	if not player_ref:
		return false

	var distance = global_position.distance_to(player_ref.global_position)
	return distance <= sound_range


func try_play_sound():
	if not sound_timer.is_stopped():
		return
# ❌ Player quá xa → không hù, không spawn ghost
	if not is_player_in_sound_range():
		return

	if spawn_sound:
		spawn_sound.play()
		sound_timer.start()
		# 👻 spawn ngẫu nhiên
		if randf() < ghost_chance:
			spawn_ghost()


func spawn_ghost():
	if not ghost_scene:
		return

	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return

	var ghost = ghost_scene.instantiate()
	get_tree().current_scene.add_child(ghost)
	ghost.setup_random(player)



func _physics_process(delta):
	if not active:
		return

	# 👻 Nếu player đang núp → enemy đi xuyên qua
	if player_ref and player_ref.is_hiding:
		set_collision_mask_value(2, false) # bỏ va chạm player
	else:
		set_collision_mask_value(2, true)
	
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	if ray_left.is_colliding():
		direction = 1
		sprite.flip_h = false
		speed += 15  
		print("speed là" +str(speed))
	if ray_right.is_colliding():
		direction = -1
		sprite.flip_h = true
		speed += 15
		print("speed là" +str(speed))

	velocity.x = direction * speed
	move_and_slide()
	
	try_play_sound()
