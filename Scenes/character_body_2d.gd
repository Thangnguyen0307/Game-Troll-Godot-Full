extends CharacterBody2D

const SPEED = 280.0
const JUMP_VELOCITY = -430.0
const FRICTION_NORMAL = 15 # Tốc độ dừng lại bình thường 
const FRICTION_ICE = 2     # Tốc độ dừng lại rất chậm khi trên băng
@onready var sprite_2d: AnimatedSprite2D = $Sprite2D
@onready var camera_2d: Camera2D = $Camera2D
var is_alive = true
var control_inverted: bool = false
var is_on_ice = false
var is_gravity_inverted = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var spawn_point_x=0
var spawn_point_y=0
# 🎨 Màu hiện tại (0 = None, 1 = Red, 2 = Yellow, ...)
var current_color: int = 0

func _ready() -> void:
	spawn_point_x=global_position.x
	spawn_point_y=global_position.y
	print(spawn_point_x)
	print(spawn_point_y)
	

func _physics_process(delta: float) -> void:
	if is_alive:
		var on_ground = is_on_ceiling() if is_gravity_inverted else is_on_floor()
		
		if (velocity.x > 1 || velocity.x < -1):
			sprite_2d.animation = "Running"
		else :
			sprite_2d.animation = "Idle"
			
		# Thêm kiểm tra bước chân
		if sprite_2d.animation == "Running" and on_ground:
			$"/root/AudioController".play_walk()
		else:
			$"/root/AudioController".stop_walk()
		
		
		# Add the gravity.
		if not on_ground:
			if is_gravity_inverted:
				velocity.y -= gravity * delta # Trọng lực hướng LÊN
				sprite_2d.animation = "Jumping" # Hoặc animation rơi ngược
			else:
				velocity.y += gravity * delta # Trọng lực hướng XUỐNG
				sprite_2d.animation = "Jumping"

		# Handle jump.
		if Input.is_action_just_pressed("jump") and on_ground:
			$"/root/AudioController".play_jump()
			if is_gravity_inverted:
				velocity.y = -JUMP_VELOCITY # Nhảy XUỐNG (vì JUMP_VELOCITY là số âm)
			else:
				velocity.y = JUMP_VELOCITY # Nhảy LÊN như bình thường

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction := Input.get_axis("left", "right")
		if control_inverted:
			direction = -direction #Đảo trí phải 
		if direction:
			velocity.x = direction * SPEED
		else:
			var current_friction = FRICTION_ICE if is_on_ice else FRICTION_NORMAL
			velocity.x = move_toward(velocity.x, 0, current_friction)

		move_and_slide()

		var isLeft = velocity.x < 0
		sprite_2d.flip_h = isLeft


func _do_reset():
	$"/root/AudioController".play_respawn()
	position = Vector2(spawn_point_x,spawn_point_y)

func die():
	GameManager.increment_death_count()
	is_alive = false
	sprite_2d.stop()
	sprite_2d.play("Hit")
	sprite_2d.play_backwards("Hit")
	# Reset tất cả các bẫy saw về vị trí ban đầu
	for saw in get_tree().get_nodes_in_group("saws"):
		if saw.has_method("reset_trap"):
			saw.reset_trap()

	# Reset lại màu
	current_color = 0
	sprite_2d.modulate = Color.WHITE
	#reset lại cơ chế nút trái phải 
	control_inverted = false
	
	await get_tree().create_timer(1.0).timeout
	_do_reset()
	
	is_alive = true
	await get_tree().create_timer(1).timeout

func _on_hurt_box_area_entered(area: Area2D) -> void:
	if area.is_in_group("hurt"):
		die()
		print(position)
		print("hit enemy")

func set_color(new_color: int):
	current_color = new_color
	match current_color:
		1: sprite_2d.modulate = Color.RED
		2: sprite_2d.modulate = Color.YELLOW
		3: sprite_2d.modulate = Color.BLUE
		4: sprite_2d.modulate = Color.GREEN
		5: sprite_2d.modulate = Color.HOT_PINK
		6: sprite_2d.modulate = Color.MAGENTA
		7: sprite_2d.modulate = Color.DARK_GRAY
		_: sprite_2d.modulate = Color.WHITE

func reset_color():
	# Reset lại màu
	current_color = 0
	sprite_2d.modulate = Color.WHITE
		
		
func _on_force_jump_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		velocity.y = JUMP_VELOCITY * 3 
	

#Hàm này làm player trơn trượt khi đi vào khối băng
func _on_icearea_body_entered(body: Node2D) -> void:
	if body == self:
		is_on_ice = true

#Hàm này làm player trơn trượt khi đi vào khối băng
func _on_icearea_body_exited(body: Node2D) -> void:
	if body == self:
		is_on_ice = false

#Hàm này làm player đảo ngược trọng lực 
func _on_view_reverse_body_entered(body: Node2D) -> void:
	if body == self:
		is_gravity_inverted = not is_gravity_inverted
		$Sprite2D.flip_v = is_gravity_inverted
