extends MarginContainer
class_name CombatAbilityTooltip

@onready var ability_name_label : Label = %AbilityNameLabel
@onready var hp_damage_label : Label = %HpDamageLabel
@onready var armor_damage_label : Label = %ArmorDamageLabel
@onready var shield_damage_label : Label = %ShieldDamageLabel

var ability_name : String = "Fireball"

func _ready() -> void:
	load_ability()

func load_ability():
	var ability : Ability = GameState.all_abilities[ability_name]

	ability_name_label.text = ability.Name
	hp_damage_label.text = str(ability.HealthDamage)
	armor_damage_label.text = str(ability.ArmorDamage)
	shield_damage_label.text = str(ability.ShieldDamage)
