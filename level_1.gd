extends Node2D

func _ready():
	# Tải cài đặt âm thanh khi khởi động game
	var config = ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		AudioServer.set_bus_mute(0, config.get_value("audio", "muted", false))

func _on_menu_button_pressed():
	$PauseMenu.show_menu()


func _on_pause_pressed() -> void:
	pass # Replace with function body.


func _on_appearing_1_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
