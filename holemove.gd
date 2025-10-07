extends Area2D

@export var tilemap_node: NodePath
@export var top_left: Vector2i = Vector2i.ZERO     # góc trên trái của vùng hố
@export var bottom_right: Vector2i = Vector2i.ZERO # góc dưới phải của vùng hố
@export var move_offset: Vector2i = Vector2i(4, 0) # dịch bao nhiêu ô (ví dụ 4 ô sang phải mỗi lần)

# Nội bộ
var tilemap: TileMap
var current_offset: Vector2i = Vector2i.ZERO
var saved_tiles: Array = []    # mảng dict { "pos": Vector2i, "source": int, "atlas": Vector2i }
var player = null
var prev_alive_state: bool = true
var has_moved_once: bool = false   # <-- cờ ngăn di chuyển nhiều lần

func _ready():
	tilemap = get_node_or_null(tilemap_node)
	player = get_tree().get_first_node_in_group("player")

	# Sinh ra toàn bộ cell trong vùng chữ nhật [top_left, bottom_right]
	var hole_cells: Array[Vector2i] = []
	for x in range(top_left.x, bottom_right.x + 1):
		for y in range(top_left.y, bottom_right.y + 1):
			hole_cells.append(Vector2i(x, y))

	# Lưu dữ liệu tile ban đầu trước khi xóa (để khôi phục chính xác sau này)
	if tilemap:
		saved_tiles.clear()
		for cell in hole_cells:
			var source_id = tilemap.get_cell_source_id(0, cell)
			var atlas_coords = tilemap.get_cell_atlas_coords(0, cell)
			saved_tiles.append({
				"pos": cell,
				"source": source_id,
				"atlas": atlas_coords
			})
			# Xóa ô để tạo hố ban đầu
			tilemap.set_cell(0, cell, -1)

	# Kết nối trigger (nếu bạn đã connect trong editor thì không sao, vẫn an toàn)
	body_entered.connect(Callable(self, "_on_body_entered"))

	# Kết nối reset khi player chết nếu player có signal player_died
	if player:
		if player.has_signal("player_died"):
			player.player_died.connect(Callable(self, "_on_player_died"))
		else:
			if player.has_method("is_alive"):
				prev_alive_state = player.is_alive
			else:
				prev_alive_state = true

	# đảm bảo monitoring bật lúc đầu để trigger có hiệu lực
	monitoring = true
	has_moved_once = false

func _process(delta):
	# Nếu không có signal player_died thì ta poll is_alive để biết player chết
	if player and not player.has_signal("player_died"):
		if prev_alive_state and player.is_alive == false:
			_on_player_died()
		prev_alive_state = player.is_alive

func _on_body_entered(body):
	# Guard: chỉ cho di chuyển 1 lần trên 1 lượt sống
	if has_moved_once:
		return

	if not body or not body.is_in_group("player"):
		return

	# Thực hiện di chuyển hố 1 lần
	move_hole()

	# Khóa trigger để tránh nhận lần tiếp (cách phụ trợ)
	monitoring = false
	has_moved_once = true

func move_hole():
	if not tilemap:
		return

	# 1) LẤP hố cũ bằng dữ liệu saved_tiles (khôi phục chính xác tile)
	for data in saved_tiles:
		var orig = data["pos"]
		var target_cell = orig + current_offset
		var src = data["source"]
		var atlas = data["atlas"]
		if src != -1:
			# khôi phục đúng tile với atlas nếu có
			tilemap.set_cell(0, target_cell, src, atlas)
		else:
			# nếu ban đầu rỗng thì giữ rỗng
			tilemap.set_cell(0, target_cell, -1)

	# 2) Dời offset (hố sẽ dịch sang phải bằng move_offset)
	current_offset += move_offset

	# 3) TẠO hố mới ở vị trí mới (xóa tile)
	for data in saved_tiles:
		var orig = data["pos"]
		var new_cell = orig + current_offset
		tilemap.set_cell(0, new_cell, -1)

func _on_player_died():
	reset_hole()

func reset_hole():
	if not tilemap:
		return

	# 1) LẤP lại hố hiện tại (nếu hố đang ở offset khác 0)
	for data in saved_tiles:
		var orig = data["pos"]
		var current_cell = orig + current_offset
		var src = data["source"]
		var atlas = data["atlas"]
		if src != -1:
			tilemap.set_cell(0, current_cell, src, atlas)
		else:
			tilemap.set_cell(0, current_cell, -1)

	# 2) Reset offset về ban đầu
	current_offset = Vector2i.ZERO

	# 3) TẠO hố ban đầu (xóa tile ở vị trí gốc)
	for data in saved_tiles:
		var orig = data["pos"]
		tilemap.set_cell(0, orig, -1)

	# Cho phép trigger hoạt động lại (một lần nữa)
	has_moved_once = false
	monitoring = true
