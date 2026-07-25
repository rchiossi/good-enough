extends MarginContainer
class_name CombatAbilityScene

@onready var sprite : TextureButton = %AbilitySprite
@onready var _cooldown_label: Label = %CooldownLabel

@onready var _press_sound: PressSound = %PressSound
@onready var _hover_sound: HoverSound = %HoverSound

@onready var _animation_hover: AnimationScaleTwitch = %AnimationScaleTwitch
@onready var _animation_click: AnimationScaleBounce = %AnimationScaleBounce

var _ability_name : String = "Cursed Explosion"
var _tooltip_scene : PackedScene = preload("res://scenes/Combat/combat_ability_tooltip.tscn")
var _in_combat : bool = true

signal show_tooltip(ability_name : String)
signal ability_activated(ability_name: String)

signal ability_hover(ability_name : String)
signal ability_hover_exit()

func _ready() -> void:
    mouse_entered.connect(func(): show_tooltip.emit(_ability_name))
    mouse_entered.connect(func(): ability_hover.emit(_ability_name))
    mouse_exited.connect(func(): ability_hover_exit.emit())
    sprite.pressed.connect(_on_sprite_pressed)

func set_ability(ability_name : String, in_combat: bool = true):
    _ability_name = ability_name
    _in_combat = in_combat

    var ability = GameState.all_abilities[ability_name]
    sprite.texture_normal = ability.icon

    tooltip_text = ability_name

    update_cooldown()

func update_cooldown():
    if not _in_combat:
        return

    var ability = GameState.all_abilities[_ability_name]
    var cooldown : int = ability.remaining_cooldown.get_or_add(GameState.player_stats.name, 0)
    if cooldown > 0:
        sprite.self_modulate = Color(0.45, 0.45, 0.45)
        _cooldown_label.text = str(cooldown)
        _cooldown_label.show()
    else:
        _cooldown_label.hide()
        sprite.self_modulate = Color.WHITE

func _make_custom_tooltip(for_text: String) -> Object:
    var tooltip : CombatAbilityTooltip = _tooltip_scene.instantiate()

    tooltip.ability_name = for_text

    return tooltip

func _on_sprite_pressed() -> void:
    var ability = GameState.all_abilities[_ability_name]
    var cooldown : int = ability.remaining_cooldown.get_or_add(GameState.player_stats.name, 0)

    if not _in_combat or cooldown == 0:
        ability_activated.emit(_ability_name)

func set_click_disabled(disabled: bool) -> void:
    sprite.disabled = disabled
    _animation_click.disabled = disabled
    _press_sound.disabled = disabled

func set_hover_disabled(disabled: bool) -> void:
    _animation_hover.disabled = disabled
    _hover_sound.disabled = disabled
