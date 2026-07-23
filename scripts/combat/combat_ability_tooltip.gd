extends MarginContainer
class_name CombatAbilityTooltip

@onready var ability_name_label : Label = %AbilityNameLabel
@onready var ability_sprite : TextureRect = %AbilitySprite
@onready var hp_damage_label : Label = %HpDamageLabel
@onready var armor_damage_label : Label = %ArmorDamageLabel
@onready var shield_damage_label : Label = %ShieldDamageLabel

var ability_name : String = "Fireball"

func _ready() -> void:
    load_ability()

func set_ability(id : String):
    ability_name = id
    load_ability()

func load_ability():
    var ability : Ability = GameState.all_abilities[ability_name]

    ability_name_label.text = ability.name
    ability_sprite.texture = ability.icon

    hp_damage_label.text = str(ability.health_damage)
    armor_damage_label.text = str(ability.armor_damage)
    shield_damage_label.text = str(ability.shield_damage)
