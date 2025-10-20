extends Area2D

@export var teleport_node: NodePath
@export var tilemap_node: NodePath
@export var spike_nodes: Array[NodePath] = []   # danh sách spike cần ẩn
@export var erase_cells: Array[Vector2i] = []   # danh sách tile cần xóa

var teleport
var tilemap
var spikes: Array = []
var saved_tiles: Array = []   # lưu tile ban đầu

var player                     # tham chiếu tới player
var has_triggered = false       # để biết khi nào teleport đã hiện

func _ready():
	teleport = get_node_or_null(teleport_node)
	tilemap = get_node_or_null(tilemap_node)

	for path in spike_nodes:
		var s = get_node_or_null(path)
		if s:
			spikes.append(s)

	# Lưu tile ban đầu
	if tilemap:
		for cell in erase_cells:
			var source_id = tilemap.get_cell_source_id(0, cell)
			var atlas_coords = tilemap.get_cell_atlas_coords(0, cell)
			saved_tiles.append({ "pos": cell, "source": source_id, "atlas": atlas_coords })

	# Ẩn teleport từ đầu
	if teleport:
		teleport.hide()

	# Tìm player trong scene
	player = get_tree().get_first_node_in_group("player")

func _on_body_entered(body):
	if body.is_in_group("player"):
		if teleport:
			teleport.show()

		if tilemap:
			for cell in erase_cells:
				tilemap.set_cell(0, cell, -1)

		for s in spikes:
			s.hide()
			disable_collision(s)

		has_triggered = true
		monitoring = false   # tắt trigger để không gọi nhiều lần

func _process(delta):
	if has_triggered and player and not player.is_alive:
		reset_state()

func reset_state():
	# Ẩn teleport
	if teleport:
		teleport.hide()

	# Khôi phục tile
	if tilemap:
		for data in saved_tiles:
			tilemap.set_cell(0, data["pos"], data["source"], data["atlas"])

	# Hiện lại spike + bật collision
	for s in spikes:
		s.show()
		enable_collision(s)

	# Cho phép trigger hoạt động lại
	monitoring = true
	has_triggered = false

func disable_collision(node):
	for child in node.get_children():
		if child is CollisionShape2D:
			child.disabled = true

func enable_collision(node):
	for child in node.get_children():
		if child is CollisionShape2D:
			child.disabled = false
