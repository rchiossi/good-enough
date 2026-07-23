extends Resource
class_name Ability

enum AbilityType {
    NORMAL, # NORMAL types cannot be forgotten, and persist indefinitely across the run
    MAGIC,
    BLUNT,
    PIERCING
}

var shield_damage: int = 0
var armor_damage: int = 0
var health_damage: int = 0
var name: String = ""
var icon := preload("uid://n1peuh4vn6i0")
var description: String = ""
var cooldown: int = 0
var remaining_cooldown: int = 0
var ability_type: AbilityType = AbilityType.NORMAL
var is_disabled: bool = false

var effect_scene: PackedScene = preload("uid://bpx7ga87e5jcc")

func take_action(source: EntityStats, target: EntityStats) -> void:
    source.deal_damage(source, shield_damage, armor_damage, health_damage)
    target.take_damage(source, shield_damage, armor_damage, health_damage)
    remaining_cooldown = cooldown
