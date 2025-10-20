extends Area2D

@onready var tilemap: TileMap = $"../TileMap"   # Đường dẫn tới TileMap, chỉnh đúng tên node của bạn

# Danh sách nhiều tọa độ tile cần xóa
@export var tiles_to_remove: Array[Vector2i] = [
	Vector2i(20, 14),
	Vector2i(21, 14),
	Vector2i(22, 14),
	Vector2i(23, 14)
]

# Lưu trạng thái ban đầu để reset
var original_tiles: Array[Dictionary] = []
var added_tiles: Array[Vector2i] = []
var has_triggered := false

func _ready():
	if not tilemap:
		push_error("❌ Không tìm thấy TileMap! Kiểm tra lại đường dẫn ../TileMap")
		return

	# Lưu tiles ban đầu
	save_original_tiles()
	
	# Thêm vào group để Player có thể reset
	add_to_group("resettable_traps")
	
	print("✅ RemoveTilemap trap ready")

func save_original_tiles():
	"""Lưu tiles gốc trước khi xóa"""
	original_tiles.clear()
	for coords in tiles_to_remove:
		var source_id = tilemap.get_cell_source_id(0, coords)
		var atlas_coords = tilemap.get_cell_atlas_coords(0, coords)
		var alternative_tile = tilemap.get_cell_alternative_tile(0, coords)

		var tile_data = {
			"coords": coords,
			"source_id": source_id,
			"atlas_coords": atlas_coords,
			"alternative_tile": alternative_tile
		}
		original_tiles.append(tile_data)
	
	print("💾 Saved ", original_tiles.size(), " original tiles for reset")

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player") and not has_triggered:
		has_triggered = true
		print("⚡ Player triggered tilemap trap!")
		
		# Xóa tiles
		for coords in tiles_to_remove:
			tilemap.set_cell(0, coords, -1)  # Xóa tile tại tọa độ đó
		
		hide() # Ẩn trigger sau khi kích hoạt

func reset_object():
	"""Reset trap về trạng thái ban đầu khi Player chết"""
	if not tilemap:
		push_error("❌ TileMap không tồn tại khi reset")
		return

	print("🔄 Resetting tilemap trap...")
	
	# Restore tiles gốc
	for tile_data in original_tiles:
		tilemap.set_cell(
			0, 
			tile_data["coords"], 
			tile_data["source_id"], 
			tile_data["atlas_coords"], 
			tile_data["alternative_tile"]
		)
	
	# Xóa tiles đã thêm trong quá trình trap
	for coords in added_tiles:
		tilemap.set_cell(0, coords, -1)
	
	# Reset trạng thái
	added_tiles.clear()
	has_triggered = false
	show()  # Hiện lại trigger
	
	print("✅ Tilemap trap reset complete!")
