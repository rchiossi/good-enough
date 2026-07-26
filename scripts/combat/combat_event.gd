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
@export var shield_change : int
@export var armor_change : int
@export var hp_change : int

