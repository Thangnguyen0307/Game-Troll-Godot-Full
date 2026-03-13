extends Control

func _ready() -> void:
	update_level_indicator()

func update_hp_bar(new_value: int) -> void:
	$Hitpoints/HitpointsBar.value = new_value

func update_level_indicator() -> void:
	$LevelIndicator/CurrentLevel.set_text(str(PlayerData.level))
