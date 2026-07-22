extends Resource
class_name EntityStats

@export var name : String

@export var max_health : int
@export var max_armor : int
@export var max_shield :int

var health : int
var armor : int
var shield : int

func init() -> void:
    health = max_health
    armor = max_armor
    shield = max_shield
<<<<<<< HEAD

func apply_damage(shield_damage: int, armor_damage: int, health_damage: int):
    shield = max(shield - shield_damage, 0)
    if shield > 0:
        return
    armor = max(armor - armor_damage, 0)
    if armor > 0:
        return
    health = max(health - health_damage, 0)
=======
>>>>>>> 9f008a3 (add map: version 0)
