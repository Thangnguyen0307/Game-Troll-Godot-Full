extends Area2D

@export var target_platforms: Array[NodePath]
@export var target_traps: Array[NodePath]
@export var activate_once: bool = true

var has_activated: bool = false

func _ready():
	body_entered.connect(_on_body_entered)
	add_to_group("activation_zones")

func _on_body_entered(body):
	# ✅ FIXED: Dùng is_in_group() thay vì begins_with() sai syntax
	if body.is_in_group("player"):
		if activate_once and has_activated:
			return
		
		# Kích hoạt platforms
		for platform_path in target_platforms:
			var platform = get_node(platform_path)
			if platform and platform.has_method("activate_platform"):
				platform.activate_platform()
		
		# Kích hoạt traps
		for trap_path in target_traps:
			var trap = get_node(trap_path)
			if trap and trap.has_method("activate_trap"):
				trap.activate_trap()
		
		has_activated = true
		print("Platforms and traps activated!")

func reset_zone():
	has_activated = false
	print("ActivationZone reset: ", name)
