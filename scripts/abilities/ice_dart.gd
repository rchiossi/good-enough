extends Resource
class_name IceDart

@export var ShieldDamage: int = 25
@export var ArmorDamage: int = 0
@export var HealthDamage: int = 3
@export var Name: String = "Ice Dart"
@export var Icon := preload("uid://qscf336gkfa4")
@export var Description: String = "An ice dart that shoots towards your enemy. Piercing them dealing significant magic damage, but fails to penetrate armor."

func take_action(stats: EntityStats) -> void:
    stats.apply_damage(ShieldDamage, ArmorDamage, HealthDamage)
