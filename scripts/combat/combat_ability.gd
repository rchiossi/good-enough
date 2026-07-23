extends MarginContainer
class_name CombatAbilityScene

@onready var sprite : TextureButton = %AbilitySprite

var _ability_name : String = "Fireball"
var _cooldown_label: Label = Label.new()

var _tooltip_scene : PackedScene = preload("res://scenes/Combat/combat_ability_tooltip.tscn")

signal show_tooltip(ability_name : String)
signal ability_activated(ability_name: String)

func _ready() -> void:
    mouse_entered.connect(func(): show_tooltip.emit(_ability_name))
    sprite.pressed.connect(_on_sprite_pressed)
    _cooldown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _cooldown_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    _cooldown_label.add_theme_font_size_override("font_size", 64)

func set_ability(ability_name : String):
    _ability_name = ability_name

    var ability = GameState.all_abilities[ability_name]
    sprite.texture_normal = ability.icon

    tooltip_text = ability_name

    update_cooldown()

func update_cooldown():
    var ability = GameState.all_abilities[_ability_name]
    if ability.remaining_cooldown > 0:
        sprite.self_modulate = Color(0.45, 0.45, 0.45)
        _cooldown_label.text = str(ability.remaining_cooldown)
        sprite.add_child(_cooldown_label)
    else:
        sprite.remove_child(_cooldown_label)

func _make_custom_tooltip(for_text: String) -> Object:
    var tooltip : CombatAbilityTooltip = _tooltip_scene.instantiate()

    tooltip.ability_name = for_text

    return tooltip

func _on_sprite_pressed() -> void:
    if GameState.player_stats.abilities[_ability_name].remaining_cooldown == 0:
        ability_activated.emit(_ability_name)