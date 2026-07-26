extends MarginContainer
class_name CombatAbilityTooltip

@onready var ability_name_label : Label = %AbilityNameLabel
@onready var ability_sprite : TextureRect = %AbilitySprite

@onready var hp_damage_label : Label = %HpDamageLabel
@onready var armor_damage_label : Label = %ArmorDamageLabel
@onready var shield_damage_label : Label = %ShieldDamageLabel

@onready var hp_regen_label : Label = %HpRegenLabel
@onready var armor_regen_label : Label = %ArmorRegenLabel
@onready var shield_regen_label : Label = %ShieldRegenLabel

@onready var description_label : RichTextLabel = %DescriptionLabel

var ability_name : String = "Cursed Explosion"

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
    
    hp_regen_label.text = str(ability. health_regeneration)
    armor_regen_label.text = str(ability.armor_regeneration)
    shield_regen_label.text = str(ability.shield_regeneration)

    description_label.text = ability.description
