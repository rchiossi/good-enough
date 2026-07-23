extends MarginContainer
class_name CombatAbilityScene

@onready var sprite : TextureButton = %AbilitySprite

var _ability_name : String = "Fireball"

var _tooltip_scene : PackedScene = preload("res://scenes/Combat/combat_ability_tooltip.tscn")

signal show_tooltip(ability_name : String)
signal ability_activated(ability_name: String)

func _ready() -> void:
    mouse_entered.connect(func(): show_tooltip.emit(_ability_name))
    sprite.pressed.connect(func(): ability_activated.emit(_ability_name))

func set_ability(ability_name : String):
    _ability_name = ability_name

    sprite.texture_normal = GameState.all_abilities[ability_name].icon

    tooltip_text = ability_name

func _make_custom_tooltip(for_text: String) -> Object:
    var tooltip : CombatAbilityTooltip = _tooltip_scene.instantiate()

    tooltip.ability_name = for_text

    return tooltip
