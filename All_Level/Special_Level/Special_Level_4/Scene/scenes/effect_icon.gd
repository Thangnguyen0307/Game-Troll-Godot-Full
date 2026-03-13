extends Control

@onready var stack_label = $StackLabel
@onready var progress_bar = $ProgressBar
@onready var icon = $Icon

var stack = 1
var duration = 0
var time_left = 0

func setup(effect_name:String, dur:float):

	duration = dur
	time_left = dur

	stack_label.text = "x1"

	load_icon(effect_name)


func add_stack(extra_time:float):

	stack += 1
	stack_label.text = "x" + str(stack)

	time_left += extra_time


func _process(delta):

	time_left -= delta

	progress_bar.value = clamp((time_left / duration) * 100, 0, 100)

	if time_left <= 0:

		stack -= 1

		if stack <= 0:
			queue_free()
		else:
			time_left = duration
			stack_label.text = "x" + str(stack)


func load_icon(effect_name):

	match effect_name:
		"speed_buff":
			icon.texture = preload("res://All_Level/Special_Level/Special_Level_4/Scene/sprite/items/icon (1).jpg")
		"speed_debuff":
			icon.texture = preload("res://All_Level/Special_Level/Special_Level_4/Scene/sprite/items/icon (2).jpg")
		"damage_buff":
			icon.texture = preload("res://All_Level/Special_Level/Special_Level_4/Scene/sprite/items/icon (3).jpg")
		"damage_debuff":
			icon.texture = preload("res://All_Level/Special_Level/Special_Level_4/Scene/sprite/items/icon (4).jpg")
