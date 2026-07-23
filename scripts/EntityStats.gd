extends Resource
class_name EntityStats

@export var name : String
@export var sprite : Texture2D

@export var max_health : int
@export var max_armor : int
@export var max_shield : int

@export var is_player : bool

@export var abilities : Dictionary[String, Ability] = {}

var health : int
var armor : int
var shield : int

signal hp_changed(old : int, new : int)
signal armor_changed(old : int, new : int)
signal shield_changed(old : int, new : int)
signal damage_taken(shield: int, armor: int, hp: int)

func init() -> void:
    health = max_health
    armor = max_armor
    shield = max_shield

func apply_damage(shield_damage: int, armor_damage: int, health_damage: int):
    var total_shield_damage = 0
    var total_armor_damage = 0
    var total_hp_damage = 0

    var new_shield : int = max(shield - shield_damage, 0)
    if new_shield != shield:
        shield_changed.emit(shield, new_shield)
        total_shield_damage = shield - new_shield
    shield = new_shield
    if shield > 0:
        damage_taken.emit(total_shield_damage, total_armor_damage, total_hp_damage)
        return

    var new_armor : int = max(armor - armor_damage, 0)
    if new_armor != armor:
        armor_changed.emit(armor, new_armor)
        total_armor_damage = armor - new_armor
    armor = new_armor
    if armor > 0:
        damage_taken.emit(total_shield_damage, total_armor_damage, total_hp_damage)
        return

    var new_health : int = max(health - health_damage, 0)
    if new_health != health:
        hp_changed.emit(health, new_health)
        total_hp_damage = health - new_health
        damage_taken.emit(total_shield_damage, total_armor_damage, total_hp_damage)
    health = new_health
