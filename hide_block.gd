extends Area2D

@export var tilemap_node: NodePath
@export var block_cell: Vector2i   # tọa độ ô tile trong tilemap

var tilemap: TileMap
var saved_tile = null   # lưu dữ liệu tile gốc (source + atlas)
var is_block_shown := false
var player = null
var prev_alive_state: bool = true

func _ready():
	tilemap = get_node_or_null(tilemap_node)
	player = get_tree().get_first_node_in_group("player")

	if not tilemap:
		return

	# Lưu dữ liệu tile ban đầu
	var source_id = tilemap.get_cell_source_id(0, block_cell)
	var atlas = tilemap.get_cell_atlas_coords(0, block_cell)

	saved_tile = {
		"source": source_id,
		"atlas": atlas
	}

	# Ban đầu ẩn block (xóa tile)
	tilemap.set_cell(0, block_cell, -1)

	# Kết nối trigger
	body_entered.connect(_on_body_entered)

	# Reset khi player chết
	if player:
		if player.has_signal("player_died"):
			player.player_died.connect(_on_player_died)
		elif player.has_method("is_alive"):
			prev_alive_state = player.is_alive

func _process(delta):
	# Nếu player không có signal thì theo dõi is_alive
	if player and not player.has_signal("player_died"):
		if prev_alive_state and player.is_alive == false:
			_on_player_died()
		prev_alive_state = player.is_alive

func _on_body_entered(body):
	if not body or not body.is_in_group("player"):
		return

	# Kiểm tra hướng nhảy lên
	if body.has_method("get_velocity"):
		var vel = body.get_velocity()
		if vel.y < 0 and not is_block_shown:
			_show_block()
	else:
		# Fallback: nếu player thấp hơn block và đi lên
		if body.global_position.y > global_position.y and not is_block_shown:
			_show_block()

func _show_block():
	if not tilemap or not saved_tile:
		return
	if saved_tile["source"] != -1:
		tilemap.set_cell(0, block_cell, saved_tile["source"], saved_tile["atlas"])
	is_block_shown = true

func _on_player_died():
	_reset_block()

func _reset_block():
	if not tilemap:
		return
	# Xóa tile (ẩn block đi)
	tilemap.set_cell(0, block_cell, -1)
	is_block_shown = false
