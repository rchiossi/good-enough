extends Resource
class_name Fireball

@export var ShieldDamage: int = 10
@export var ArmorDamage: int = 10
@export var HealthDamage: int = 10
@export var IconPath: String = "res://assets/icon.svg"

func take_action(stats: EntityStats) -> void:
	stats.apply_damage(ShieldDamage, ArmorDamage, HealthDamage)
