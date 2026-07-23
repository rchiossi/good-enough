extends Resource
class_name Ability

var shield_damage: int = 0
var armor_damage: int = 0
var health_damage: int = 0
var name: String = ""
var icon := preload("uid://n1peuh4vn6i0")
var description: String = ""

func take_action(stats: EntityStats) -> void:
    stats.apply_damage(shield_damage, armor_damage, health_damage)
