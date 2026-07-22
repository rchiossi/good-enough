extends Resource
class_name Fireball

@export var ShieldDamage: int = 10
@export var ArmorDamage: int = 10
@export var HealthDamage: int = 10
@export var Name: String = "Fireball"
@export var IconPath: String = "res://assets/icon.svg"
@export var Description: String = "A fireball that explodes onto your enemies. They'll never see it coming. Well they will, but they'll be too late."

func take_action(stats: EntityStats) -> void:
    stats.apply_damage(ShieldDamage, ArmorDamage, HealthDamage)
