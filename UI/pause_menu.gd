extends CanvasLayer

var is_sound_on = true
var tween: Tween

func _ready():
	visible = false
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	setup_button_signals()

func show_menu():
	visible = true
	get_tree().paused = true

func hide_menu():
	visible = false
	get_tree().paused = false

func animate_button_down(button: Node):
	if tween:
		tween.kill()
	tween = create_tween()
	var original_scale = button.scale
	tween.tween_property(button, "scale", original_scale * 0.9, 0.1)

func animate_button_up(button: Node):
	if tween:
		tween.kill()
	tween = create_tween()
	var original_scale = button.scale / 0.9
	tween.tween_property(button, "scale", original_scale, 0.1)

func setup_button_signals():
	# Get TouchScreenButton references
	var replay_touch = $"CenterContainer/VBoxContainer/ReplayButton/ReplayTouch"
	var home_touch = $"CenterContainer/VBoxContainer/HomeButton/home"
	var sound_touch = $"CenterContainer/VBoxContainer/SoundButton/Sound"
	var continue_touch = $"CenterContainer/VBoxContainer/Continue/Continue"
	
	# Disconnect existing pressed signals and connect new pressed/released signals
	if replay_touch:
		replay_touch.pressed.disconnect(_on_replay_button_pressed)
		replay_touch.pressed.connect(_on_replay_button_down)
		replay_touch.released.connect(_on_replay_button_up)
	
	if home_touch:
		home_touch.pressed.disconnect(_on_home_button_pressed)
		home_touch.pressed.connect(_on_home_button_down)
		home_touch.released.connect(_on_home_button_up)
	
	if sound_touch:
		sound_touch.pressed.disconnect(_on_sound_button_pressed)
		sound_touch.pressed.connect(_on_sound_button_down)
		sound_touch.released.connect(_on_sound_button_up)
	
	if continue_touch:
		continue_touch.pressed.disconnect(_on_continue_pressed)
		continue_touch.pressed.connect(_on_continue_button_down)
		continue_touch.released.connect(_on_continue_button_up)

# Continue button
func _on_continue_button_down():
	animate_button_down($"CenterContainer/VBoxContainer/Continue")

func _on_continue_button_up():
	animate_button_up($"CenterContainer/VBoxContainer/Continue")
	$"/root/AudioController".play_click()
	hide_menu()

# Replay button
func _on_replay_button_down():
	animate_button_down($"CenterContainer/VBoxContainer/ReplayButton")

func _on_replay_button_up():
	animate_button_up($"CenterContainer/VBoxContainer/ReplayButton")
	$"/root/AudioController".play_click()
	get_tree().paused = false
	get_tree().reload_current_scene()

# Home button
func _on_home_button_down():
	animate_button_down($"CenterContainer/VBoxContainer/HomeButton")

func _on_home_button_up():
	animate_button_up($"CenterContainer/VBoxContainer/HomeButton")
	$"/root/AudioController".play_click()
	get_tree().paused = false
	get_tree().change_scene_to_file.call_deferred("res://Scene Main Start/main.tscn")

# Sound button
func _on_sound_button_down():
	animate_button_down($"CenterContainer/VBoxContainer/SoundButton")

func _on_sound_button_up():
	animate_button_up($"CenterContainer/VBoxContainer/SoundButton")
	$"/root/AudioController".play_click()
	is_sound_on = !is_sound_on
	AudioServer.set_bus_mute(0, !is_sound_on)
	if is_sound_on:
		$CenterContainer/VBoxContainer/SoundButton.text = "Tắt âm thanh"
	else:
		$CenterContainer/VBoxContainer/SoundButton.text = "Bật âm thanh"

# Keep old functions for compatibility (won't be used)
func _on_continue_button_pressed():
	pass

func _on_replay_button_pressed():
	pass

func _on_home_button_pressed():
	pass

func _on_sound_button_pressed():
	pass

func _on_continue_pressed() -> void:
	pass


func _on_pause_pressed() -> void:
	pass # Replace with function body.
