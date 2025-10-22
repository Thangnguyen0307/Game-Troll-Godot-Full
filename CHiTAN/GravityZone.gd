extends Area2D
class_name GravityZone

## Vùng hút với trọng lực tùy chỉnh - giống như hố đen
## Khi player vào vùng này sẽ bị hút vào tâm

@export_group("Gravity Settings")
@export var gravity_strength: float = 500.0  ## Lực hút (pixels/s²)
@export var attraction_radius: float = 200.0  ## Phạm vi hút (pixels)
@export var max_pull_speed: float = 400.0  ## Tốc độ hút tối đa
@export var disable_world_gravity: bool = true  ## Tắt trọng lực Godot khi vào vùng này?

@export_group("Visual Settings")
@export var show_debug_circle: bool = true  ## Hiển thị vòng tròn phạm vi
@export var core_color: Color = Color(0.2, 0.1, 0.3, 0.8)  ## Màu tâm hút
@export var field_color: Color = Color(0.4, 0.2, 0.6, 0.3)  ## Màu vùng hút

@export_group("Kill Settings")
@export var kill_at_center: bool = false  ## Player chết khi chạm vào tâm?
@export var center_kill_radius: float = 20.0  ## Bán kính vùng chết (nếu bật)

var players_in_zone: Array = []
var center_position: Vector2
var players_with_disabled_gravity: Array = []  # Danh sách player đã tắt gravity

func _ready():
	# Thêm vào group để player có thể tìm thấy
	add_to_group("gravity_zones")
	
	# Setup collision shape dựa trên attraction_radius
	setup_collision_shape()
	
	# Lưu vị trí tâm
	center_position = global_position
	
	# Kết nối signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# QUAN TRỌNG: Set monitoring để nhận signals
	monitoring = true
	monitorable = false
	
	# Set collision layers - detect tất cả
	collision_layer = 0  
	collision_mask = 1 + 2 + 4  # Detect layer 1, 2, 3
	
	print("🌌 GravityZone created at: ", global_position)
	print("   Attraction radius: ", attraction_radius)
	print("   Gravity strength: ", gravity_strength)

func setup_collision_shape():
	"""Tạo hoặc cập nhật collision shape"""
	# Xóa các collision shapes cũ
	for child in get_children():
		if child is CollisionShape2D:
			child.queue_free()
	
	# Tạo collision shape mới
	var collision = CollisionShape2D.new()
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = attraction_radius
	collision.shape = circle_shape
	add_child(collision)

func _process(delta: float):
	# Cập nhật tâm hút (nếu vật di chuyển)
	center_position = global_position
	
	# Áp dụng lực hút cho tất cả player trong vùng
	for player in players_in_zone:
		if is_instance_valid(player):
			apply_gravity_to_player(player, delta)
		else:
			players_in_zone.erase(player)

func apply_gravity_to_player(player, delta: float):
	"""Áp dụng lực hút vào player"""
	if not is_instance_valid(player):
		return
	
	# Tính vector từ player đến tâm
	var direction = center_position - player.global_position
	var distance = direction.length()
	
	# Kiểm tra nếu player ở trong vùng kill
	if kill_at_center and distance < center_kill_radius:
		if player.has_method("die"):
			player.die()
		return
	
	# Tính lực hút (giảm dần theo khoảng cách)
	if distance > 0:
		direction = direction.normalized()
		
		# Lực hút mạnh hơn khi gần tâm (inverse square law)
		var distance_factor = 1.0 - (distance / attraction_radius)
		distance_factor = clamp(distance_factor, 0.0, 1.0)
		
		# Tính acceleration (lực hút)
		var pull_acceleration = direction * gravity_strength * distance_factor
		
		# Áp dụng trực tiếp lên velocity
		if player is CharacterBody2D:
			# QUAN TRỌNG: Thêm vào velocity MỖI frame
			player.velocity += pull_acceleration * delta
			
			# In debug để kiểm tra
			if Engine.get_process_frames() % 30 == 0:  # Print mỗi 30 frames
				print("Pulling player! Distance: ", distance, " Force: ", pull_acceleration.length())

func _on_body_entered(body):
	"""Khi có vật vào vùng hút"""
	if body.is_in_group("player"):
		if not body in players_in_zone:
			players_in_zone.append(body)
			
			# Đánh dấu player để tắt gravity trong _physics_process
			if disable_world_gravity:
				if not body in players_with_disabled_gravity:
					players_with_disabled_gravity.append(body)
				print("🌌 Player entered gravity zone! World gravity will be DISABLED")
			else:
				print("🌌 Player entered gravity zone!")

func _on_body_exited(body):
	"""Khi vật rời khỏi vùng hút"""
	if body.is_in_group("player"):
		players_in_zone.erase(body)
		
		# Bỏ đánh dấu tắt gravity
		if body in players_with_disabled_gravity:
			players_with_disabled_gravity.erase(body)
			print("🌍 Player exited gravity zone! World gravity RESTORED")
		else:
			print("🌍 Player exited gravity zone!")

func is_player_gravity_disabled(player) -> bool:
	"""Kiểm tra xem player này có bị tắt gravity không"""
	return disable_world_gravity and (player in players_with_disabled_gravity)

func _draw():
	"""Vẽ visual cho gravity zone"""
	if not show_debug_circle:
		return
	
	# Vẽ vòng tròn phạm vi hút
	draw_circle(Vector2.ZERO, attraction_radius, field_color)
	
	# Vẽ đường viền
	draw_arc(Vector2.ZERO, attraction_radius, 0, TAU, 64, Color(0.6, 0.3, 0.8, 0.6), 2.0)
	
	# Vẽ tâm hút
	draw_circle(Vector2.ZERO, 15, core_color)
	
	# Vẽ vùng kill nếu bật
	if kill_at_center:
		draw_circle(Vector2.ZERO, center_kill_radius, Color(1.0, 0.0, 0.0, 0.5))

# Cập nhật visual khi thay đổi settings trong Inspector
func _set(property: StringName, value: Variant) -> bool:
	match property:
		"attraction_radius":
			attraction_radius = value
			if is_inside_tree():
				setup_collision_shape()
				queue_redraw()
			return true
		"show_debug_circle", "core_color", "field_color", "kill_at_center", "center_kill_radius":
			queue_redraw()
			return true
	return false
