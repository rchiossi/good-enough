extends Resource
class_name Ability

var shield_damage: int = 0
var armor_damage: int = 0
var health_damage: int = 0
var name: String = ""
var icon := preload("uid://n1peuh4vn6i0")
var description: String = ""
var cooldown: int = 0

func take_action(source: EntityStats, target: EntityStats) -> void:
    source.deal_damage(source, shield_damage, armor_damage, health_damage)
    target.take_damage(source, shield_damage, armor_damage, health_damage)
