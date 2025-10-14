extends Area2D

# Tách riêng các type
@export_group("Targets - AnimatableBody2D")
@export var moving_platforms: Array[AnimatableBody2D] = []  # ✅ CHỈ NHẬN AnimatableBody2D

@export_group("Targets - Area2D") 
@export var deadly_traps: Array[Area2D] = []  # ✅ CHỈ NHẬN Area2D

@export_group("Settings")
@export var activate_once: bool = true
@export var auto_reset_on_death: bool = true

var has_activated: bool = false

func _ready():
	body_entered.connect(_on_body_entered)
	add_to_group("activation_zones")
	
	if auto_reset_on_death:
		connect_to_player_death()

func connect_to_player_death():
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_signal("player_died"):
		player.player_died.connect(reset_zone)

func _on_body_entered(body):
	if not body.is_in_group("player"):
		return
	
	if activate_once and has_activated:
		return
	
	activate_targets()
	has_activated = true

func activate_targets():
	# Kích hoạt platforms
	for platform in moving_platforms:
		if platform and platform.has_method("activate_platform"):
			platform.activate_platform()
			print("✅ Activated platform: ", platform.name)
	
	# Kích hoạt traps
	for trap in deadly_traps:
		if trap and trap.has_method("activate_trap"):
			trap.activate_trap()
			print("✅ Activated trap: ", trap.name)

func reset_zone():
	has_activated = false
	print("ActivationZone reset: ", name)
