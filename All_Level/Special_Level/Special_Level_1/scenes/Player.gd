extends CharacterBody2D

# ================== CẤU HÌNH CHUNG ==================
const WALK_SPEED = 150.0
const GRAVITY = 980.0

# ================== JUMP KING ==================
const MAX_JUMP_FORCE = -700.0
const MIN_JUMP_FORCE = -150.0
const CHARGE_SPEED = 600.0

# ================== WALL BUMP (NẢY TƯỜNG) ==================
const WALL_BUMP_UP = -350.0       # Lực đẩy LÊN khi nảy tường
const WALL_BUMP_SIDE = 200.0      # Lực đẩy NGANG (bật sang hướng đối diện)
const WALL_BUMP_MIN_SPEED = 200.0 # Tốc độ tối thiểu (velocity.length) để kích hoạt nảy
var wall_bumped = false

var current_jump_force = MIN_JUMP_FORCE
var is_charging = false

# ================== SLIDE (TRƯỢT DỐC) ==================
const SLIDE_ACCELERATION = 50000.0
const SLIDE_MAX_SPEED = 1500.0
const SLIDE_THRESHOLD = 43.0 # độ

# ================== NGÃ SẤP MẶT (STUN) ==================
const HARD_LANDING_THRESHOLD = 800.0
const STUN_DURATION = 0.5

var is_stunned = false
var stun_timer = 0.0
var last_frame_velocity_y = 0.0

# ================== NODE ==================
@onready var sprite: AnimatedSprite2D = $Sprite2D


func _physics_process(delta):
	# ================== TRỌNG LỰC ==================
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# ================== ĐANG STUN → KHÓA ĐIỀU KHIỂN ==================
	if is_stunned:
		stun_timer -= delta

		# vẫn cho rơi / bám đất tự nhiên
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, WALK_SPEED)

		move_and_slide()

		# Hết stun
		if stun_timer <= 0:
			is_stunned = false
			sprite.play("idle")

		return

	# ================== KIỂM TRA TRƯỢT ==================
	var is_sliding = false
	if is_on_floor():
		var normal = get_floor_normal()
		var floor_angle = rad_to_deg(normal.angle_to(Vector2.UP))

		if abs(floor_angle) > SLIDE_THRESHOLD:
			is_sliding = true
			var slide_dir = Vector2.DOWN.slide(normal).normalized()
			velocity += slide_dir * SLIDE_ACCELERATION * delta

			velocity.x = clamp(velocity.x, -SLIDE_MAX_SPEED, SLIDE_MAX_SPEED)
			velocity.y = clamp(velocity.y, -SLIDE_MAX_SPEED, SLIDE_MAX_SPEED)

	# ================== LOGIC ĐIỀU KHIỂN ==================
	if is_sliding:
		# ---- TRƯỢT ----
		is_charging = false
		current_jump_force = MIN_JUMP_FORCE

		if velocity.x > 0:
			sprite.flip_h = false
		elif velocity.x < 0:
			sprite.flip_h = true

	else:
		# ---- JUMP KING ----
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, WALK_SPEED)

			# ===== GỒNG NHẢY =====
			if Input.is_action_pressed("jump"):
				$"/root/AudioController".play_jump()
				is_charging = true
				current_jump_force -= CHARGE_SPEED * delta
				current_jump_force = max(current_jump_force, MAX_JUMP_FORCE)

			# ===== THẢ NHẢY =====
			elif Input.is_action_just_released("jump") and is_charging:
				$"/root/AudioController".play_jump()
				velocity.y = current_jump_force

				var dir = Input.get_axis("left", "right")
				if dir != 0:
					velocity.x = dir * WALK_SPEED * 1.5
					sprite.flip_h = dir < 0
				else:
					velocity.x = 0 # NHẢY THẲNG

				is_charging = false
				current_jump_force = MIN_JUMP_FORCE

			# ===== ĐI BỘ =====
			else:
				is_charging = false
				current_jump_force = MIN_JUMP_FORCE

				var direction = Input.get_axis("left", "right")
				if direction:
					velocity.x = direction * WALK_SPEED
					sprite.flip_h = direction < 0

	# ================== ANIMATION + SOUND ==================
	if not is_on_floor():
		sprite.play("jump")
		$"/root/AudioController".stop_walk()

	elif is_sliding:
		sprite.play("jump") # hoặc "slide"
		$"/root/AudioController".stop_walk()

	elif is_charging:
		sprite.play("changing") # gồng nhảy
		$"/root/AudioController".stop_walk()

	else:
		var direction = Input.get_axis("left", "right")

		if direction != 0:
			sprite.play("run")
			$"/root/AudioController".play_walk()
		else:
			sprite.play("idle")
			$"/root/AudioController".stop_walk()
		

	# ================== KIỂM TRA NGÃ ==================
	last_frame_velocity_y = velocity.y
	move_and_slide()

	if is_on_floor():
		wall_bumped = false
		if last_frame_velocity_y > HARD_LANDING_THRESHOLD:
			$"/root/AudioController".play_fall()
			start_faceplant()

	# ================== NẢY TƯỜNG (WALL BUMP) ==================
	elif not is_stunned:
		var wall_normal_x = 0.0
		for i in get_slide_collision_count():
			var col = get_slide_collision(i)
			var normal = col.get_normal()
			# Normal nằm ngang → tường dọc (trái/phải)
			if abs(normal.x) > 0.7:
				wall_normal_x = normal.x
				break

		if wall_normal_x != 0.0 and not wall_bumped:
			# Chỉ nảy khi đủ tốc độ
			if velocity.length() >= WALL_BUMP_MIN_SPEED:
				wall_bumped = true
				# Bật sang hướng đối diện: chạm tường trái (normal.x > 0) → bật phải, ngược lại
				velocity.x = sign(wall_normal_x) * WALL_BUMP_SIDE
				velocity.y = WALL_BUMP_UP
				sprite.flip_h = wall_normal_x < 0
		elif wall_normal_x == 0.0:
			wall_bumped = false


# ================== FACEPLANT ==================
func start_faceplant():
	print("Á đau quá! Va chạm:", last_frame_velocity_y)

	is_stunned = true
	stun_timer = STUN_DURATION

	velocity = Vector2.ZERO
	sprite.play("faceplant")

	# ================== ĐẾM NGÃ → POPUP SAU 5 LẦN ==================
	if has_node("/root/Death5PopupManager"):
		$"/root/Death5PopupManager".add_death()
	else:
		push_warning("Player: Không tìm thấy Death5PopupManager trong autoload!")
