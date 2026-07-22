extends MarginContainer
class_name CombatAbilityScene

var _ability_name : String = "Fireball"

var _tooltip_scene : PackedScene = preload("res://scenes/Combat/combat_ability_tooltip.tscn")

#func _init(ability_name : String):
	#_ability_name = ability_name

func _ready() -> void:
	tooltip_text = _ability_name

func _make_custom_tooltip(for_text: String) -> Object:
	var tooltip : CombatAbilityTooltip = _tooltip_scene.instantiate()

	tooltip.set_ability(_ability_name)

	return tooltip