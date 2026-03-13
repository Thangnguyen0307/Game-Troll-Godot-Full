extends Area2D

const FLOATING_TEXT = preload("res://All_Level/Special_Level/Special_Level_4/Scene/scenes/floating_text.tscn")

enum EffectType {
	HEAL,
	SPEED_UP,
	DAMAGE_UP,
	LEVEL_UP,
	DAMAGE_SELF,
	SPEED_DOWN,
	DAMAGE_DOWN,
	LEVEL_DOWN
}

@export var buff_duration: float = 20.0
@export var debuff_duration: float = 60.0
@export var buff_chance: float = 0.6


func _ready():
	body_entered.connect(_on_body_entered)


func _on_body_entered(body):

	if not body.is_in_group("Player"):
		return

	set_deferred("monitoring", false)

	apply_random_effect(body)

	queue_free()


func apply_random_effect(player):

	if randf() < buff_chance:
		apply_buff(player)
	else:
		apply_debuff(player)


func apply_buff(player):

	var buffs = [
		EffectType.HEAL,
		EffectType.SPEED_UP,
		EffectType.DAMAGE_UP,
		EffectType.LEVEL_UP
	]

	var effect = buffs.pick_random()

	match effect:

		EffectType.HEAL:
			player.heal(30)
			show_text("+HP", Color.GREEN)

		EffectType.SPEED_UP:
			player.apply_temp_buff("speed",150,buff_duration)
			show_text("+Speed", Color.LIGHT_GRAY)

		EffectType.DAMAGE_UP:
			player.apply_temp_buff("damage",30,buff_duration)
			show_text("+Damage", Color.ORANGE)

		EffectType.LEVEL_UP:
			var exp = randi_range(300,900)
			player.gain_experience(exp)
			show_text("+EXP " + str(exp), Color.GOLD)


func apply_debuff(player):

	var debuffs = [
		EffectType.DAMAGE_SELF,
		EffectType.SPEED_DOWN,
		EffectType.DAMAGE_DOWN,
		EffectType.LEVEL_DOWN
	]

	var effect = debuffs.pick_random()

	match effect:

		EffectType.DAMAGE_SELF:
			player.take_random_damage()
			show_text("-HP", Color.RED)

		EffectType.SPEED_DOWN:
			player.apply_temp_buff("speed",-100,debuff_duration)
			show_text("-Speed", Color.DARK_GRAY)

		EffectType.DAMAGE_DOWN:
			player.apply_temp_buff("damage",-20,debuff_duration)
			show_text("-Damage", Color.DARK_RED)

		EffectType.LEVEL_DOWN:
			var exp = -randi_range(300,800)
			player.gain_experience(exp)
			show_text("-EXP", Color.GOLDENROD)


func show_text(text,color):

	var t = FLOATING_TEXT.instantiate()
	t.global_position = global_position

	var effects = get_tree().get_first_node_in_group("effects")

	if effects:
		effects.add_child(t)
	else:
		get_tree().current_scene.add_child(t)

	t.setup(text,color)
