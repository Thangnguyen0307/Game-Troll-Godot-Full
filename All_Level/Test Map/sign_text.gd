extends Label

@export var show_time := 2.0

@export var taunts := [
	"Curiosity is a trap.",
	"This is what curiosity gets you.",
	"Not such a good idea, was it?",
	"You walked right into it.",
	"Bad idea.",
	"What are you looking for there?",
	"You really thought this was safe?",
	"Curiosity got the better of you."
]

func _ready():
	visible = false

func on_trap_entered(body):
	if not body.is_in_group("player"):
		return

	text = taunts.pick_random()
	visible = true

	await get_tree().create_timer(show_time).timeout
	visible = false
