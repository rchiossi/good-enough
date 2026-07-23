extends Resource
class_name CombatEvent

enum CombatEventType {
    DAMAGE,
    DEATH
}

@export var type : CombatEventType

@export var source : EntityStats
@export var target : EntityStats

@export var ability : Ability

# For Damage Events
@export var shield_damage : int
@export var armor_damage : int
@export var hp_damage : int

