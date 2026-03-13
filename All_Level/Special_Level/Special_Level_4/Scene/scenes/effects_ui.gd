extends HBoxContainer

const EFFECT_ICON = preload("res://All_Level/Special_Level/Special_Level_4/Scene/scenes/effect_icon.tscn")

var effects = {}

func add_effect(effect_name:String, duration:float):

	if effects.has(effect_name):
		effects[effect_name].add_stack(duration)
	else:
		var icon = EFFECT_ICON.instantiate()
		add_child(icon)

		icon.setup(effect_name, duration)

		effects[effect_name] = icon

		icon.tree_exited.connect(_on_icon_removed.bind(effect_name))


func _on_icon_removed(effect_name):
	effects.erase(effect_name)


func clear_effects():
	for icon in effects.values():
		if is_instance_valid(icon):
			icon.queue_free()

	effects.clear()
