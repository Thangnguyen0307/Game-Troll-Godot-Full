extends Area2D
class_name GravityFieldZone

## Vùng thay đổi trọng lực - không hút vào tâm, chỉ thay đổi hướng/cường độ gravity
## Dùng để tạo trọng lực ngược, trọng lực ngang, giảm trọng lực, v.v.

@export_group("Gravity Settings")
@export var custom_gravity: Vector2 = Vector2(0, 980)  ## Vector trọng lực tùy chỉnh (x, y)
@export var gravity_multiplier: float = 1.0  ## Hệ số nhân với trọng lực (0 = không trọng lực, 2 = gấp đôi)
@export var override_gravity: bool = true  ## true = thay thế hoàn toàn, false = cộng thêm

@export_group("Zone Shape")
@export var zone_width: float = 300.0  ## Chiều rộng vùng (Rectangle)
@export var zone_height: float = 400.0  ## Chiều cao vùng (Rectangle)
@export var use_rectangle: bool = true  ## true = hình chữ nhật, false = hình tròn
@export var zone_radius: float = 200.0  ## Bán kính (nếu dùng Circle)

@export_group("Visual Settings")
@export var show_debug_area: bool = true  ## Hiển thị vùng debug
@export var area_color: Color = Color(0.3, 0.5, 0.8, 0.3)  ## Màu vùng
@export var border_color: Color = Color(0.4, 0.7, 1.0, 0.6)  ## Màu viền
@export var show_gravity_arrows: bool = true  ## Hiển thị mũi tên chỉ hướng gravity

var players_in_zone: Array = []

func _ready():
	# Thêm vào group để player tìm được
	add_to_group("gravity_field_zones")
	
	# Setup collision shape
	setup_collision_shape()
	
	# Kết nối signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Setup Area2D
	monitoring = true
	monitorable = false
	collision_layer = 0
	collision_mask = 1 + 2 + 4
	
	print("⚡ GravityFieldZone created at: ", global_position)
	print("   Custom gravity: ", custom_gravity)
	print("   Multiplier: ", gravity_multiplier)

func setup_collision_shape():
	"""Tạo collision shape dựa trên settings"""
	# Xóa shapes cũ
	for child in get_children():
		if child is CollisionShape2D:
			child.queue_free()
	
	var collision = CollisionShape2D.new()
	
	if use_rectangle:
		var rect_shape = RectangleShape2D.new()
		rect_shape.size = Vector2(zone_width, zone_height)
		collision.shape = rect_shape
	else:
		var circle_shape = CircleShape2D.new()
		circle_shape.radius = zone_radius
		collision.shape = circle_shape
	
	add_child(collision)

func get_custom_gravity_for_player(player) -> Vector2:
	"""Trả về vector trọng lực tùy chỉnh cho player"""
	if player in players_in_zone:
		if override_gravity:
			# Thay thế hoàn toàn
			return custom_gravity * gravity_multiplier
		else:
			# Cộng thêm vào gravity gốc
			return player.get_gravity() + (custom_gravity * gravity_multiplier)
	
	return Vector2.ZERO

func is_player_in_zone(player) -> bool:
	"""Kiểm tra player có trong vùng không"""
	return player in players_in_zone

func _on_body_entered(body):
	if body.is_in_group("player"):
		if not body in players_in_zone:
			players_in_zone.append(body)
			print("⚡ Player entered gravity field! Gravity: ", custom_gravity * gravity_multiplier)

func _on_body_exited(body):
	if body.is_in_group("player"):
		players_in_zone.erase(body)
		print("⚡ Player exited gravity field!")

func _draw():
	"""Vẽ visual cho zone"""
	if not show_debug_area:
		return
	
	# Vẽ vùng
	if use_rectangle:
		var rect = Rect2(-zone_width/2, -zone_height/2, zone_width, zone_height)
		draw_rect(rect, area_color)
		draw_rect(rect, border_color, false, 3.0)
	else:
		draw_circle(Vector2.ZERO, zone_radius, area_color)
		draw_arc(Vector2.ZERO, zone_radius, 0, TAU, 64, border_color, 3.0)
	
	# Vẽ mũi tên chỉ hướng gravity
	if show_gravity_arrows:
		draw_gravity_arrows()

func draw_gravity_arrows():
	"""Vẽ các mũi tên chỉ hướng gravity"""
	var gravity_dir = custom_gravity.normalized()
	if gravity_dir.length() < 0.01:
		return  # Không có gravity
	
	var arrow_count = 5
	var spacing = zone_width / (arrow_count + 1) if use_rectangle else zone_radius / 2
	
	for i in range(arrow_count):
		var offset = (i - arrow_count/2.0) * spacing
		var start_pos = Vector2(offset, -zone_height/4 if use_rectangle else -zone_radius/2)
		var end_pos = start_pos + gravity_dir * 40
		
		# Vẽ đường
		draw_line(start_pos, end_pos, Color(1, 1, 0, 0.8), 2.0)
		
		# Vẽ đầu mũi tên
		var arrow_size = 8
		var perp = gravity_dir.orthogonal() * arrow_size
		draw_line(end_pos, end_pos - gravity_dir * arrow_size + perp, Color(1, 1, 0, 0.8), 2.0)
		draw_line(end_pos, end_pos - gravity_dir * arrow_size - perp, Color(1, 1, 0, 0.8), 2.0)

# Cập nhật visual khi thay đổi settings
func _set(property: StringName, value: Variant) -> bool:
	match property:
		"zone_width", "zone_height", "zone_radius", "use_rectangle":
			if is_inside_tree():
				setup_collision_shape()
				queue_redraw()
			return true
		"show_debug_area", "area_color", "border_color", "show_gravity_arrows", "custom_gravity":
			queue_redraw()
			return true
	return false
