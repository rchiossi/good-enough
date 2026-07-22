extends MarginContainer
class_name CombatAbilityScene

@onready var sprite : TextureRect = %AbilitySprite

var _ability_name : String = "Fireball"

var _tooltip_scene : PackedScene = preload("res://scenes/Combat/combat_ability_tooltip.tscn")

func set_ability(ability_name : String):
	_ability_name = ability_name

	sprite.texture = GameState.all_abilities[ability_name].Icon

	tooltip_text = ability_name

func _make_custom_tooltip(for_text: String) -> Object:
	var tooltip : CombatAbilityTooltip = _tooltip_scene.instantiate()

	tooltip.ability_name = for_text

	return tooltip
