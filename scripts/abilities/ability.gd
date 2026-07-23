extends Resource
class_name Ability

var ShieldDamage: int = 0
var ArmorDamage: int = 0
var HealthDamage: int = 0
var Name: String = ""
var Icon := preload("uid://n1peuh4vn6i0")
var Description: String = ""

func take_action(stats: EntityStats) -> void:
	stats.apply_damage(ShieldDamage, ArmorDamage, HealthDamage)
