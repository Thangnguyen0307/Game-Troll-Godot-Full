extends Area2D

@export var tilemap_node: NodePath
@export var erase_cells: Array[Vector2i] = []   # danh sách tile cần xóa
@export var teleport_node: NodePath
@export var move_distance: float = 64.0         # khoảng cách dịch sang trái
@export var move_time: float = 0.5              # thời gian di chuyển

var tilemap
var saved_tiles: Array = []   # lưu tile ban đầu

var player                     # tham chiếu tới player
var has_triggered = false       # để biết khi nào đã kích hoạt

var teleport
var teleport_start_pos: Vector2

func _ready():
	tilemap = get_node_or_null(tilemap_node)
	teleport = get_node_or_null(teleport_node)

	if teleport:
		teleport_start_pos = teleport.position

	# Lưu tile ban đầu
	if tilemap:
		for cell in erase_cells:
			var source_id = tilemap.get_cell_source_id(0, cell)
			var atlas_coords = tilemap.get_cell_atlas_coords(0, cell)
			saved_tiles.append({ "pos": cell, "source": source_id, "atlas": atlas_coords })

	# Tìm player trong scene
	player = get_tree().get_first_node_in_group("player")

func _on_body_entered(body):
	if body.is_in_group("player"):

		if tilemap:
			for cell in erase_cells:
				tilemap.set_cell(0, cell, -1)

		# Di chuyển teleport sang trái
		if teleport:
			var tween = get_tree().create_tween()
			var target_pos = teleport.position + Vector2(-move_distance, 0)
			tween.tween_property(teleport, "position", target_pos, move_time)

		has_triggered = true
		monitoring = false   # tắt trigger để không gọi nhiều lần

func _process(delta):
	if has_triggered and player and not player.is_alive:
		reset_state()

func reset_state():
	# Khôi phục tile
	if tilemap:
		for data in saved_tiles:
			tilemap.set_cell(0, data["pos"], data["source"], data["atlas"])

	# Reset lại vị trí teleport
	if teleport:
		teleport.position = teleport_start_pos

	# Cho phép trigger hoạt động lại
	monitoring = true
	has_triggered = false
