extends Resource
class_name Ability

enum AbilityType {
    NORMAL, # NORMAL types cannot be forgotten, and persist indefinitely across the run
    MAGIC,
    BLUNT,
    PIERCING
}

enum AnimationType {
    NONE,
    DEMON_BITE,
    DARK_SPIKE_EXPLOSION,
    LIGHTNING_BOLT,
    CELESTIAL_BONK,
    FIRE_TORNADO,
    WATER_BLAST,
    WATER_SURGE,
    PHOENIX_FLAME,
    BLOOD_BEND_BIG,
    BLOOD_BEND_MEDIUM,
    FROST_TOMB,
    ABYSSAL_SURGE,
    TORNADO,
    HEAL
}

var shield_damage: int = 0
var armor_damage: int = 0
var health_damage: int = 0
var shield_regeneration: int = 0
var armor_regeneration: int = 0
var health_regeneration: int = 0
var name: String = ""
var icon := preload("uid://n1peuh4vn6i0")
var description: String = ""
var cooldown: int = 0
var remaining_cooldown: Dictionary[String, int] = {}
var ability_type: AbilityType = AbilityType.NORMAL
var is_disabled: bool = false
var animation_type: AnimationType = AnimationType.CELESTIAL_BONK

var effect_scene: PackedScene = preload("uid://bpx7ga87e5jcc")

func take_action(source: EntityStats, target: EntityStats) -> void:
    if source.name == target.name:
        source.heal(source, target, shield_regeneration, armor_regeneration, health_regeneration, name)
    else:
        source.deal_damage(target, shield_damage, armor_damage, health_damage, name)
        target.take_damage(source, shield_damage, armor_damage, health_damage, name)

    remaining_cooldown[source.name] = cooldown
